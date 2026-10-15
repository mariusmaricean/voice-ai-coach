import AVFAudio
import Observation
import Speech

@MainActor
@Observable
final class VoiceCoach {
    private(set) var state: CoachState = .idle
    private(set) var liveTranscript = ""
    private(set) var reply = ""
    private(set) var errorMessage: String?

    @ObservationIgnored private let listener = SpeechListener()
    @ObservationIgnored private let speaker = SpeechSpeaker()
    @ObservationIgnored private let llm: any LLMClient
    @ObservationIgnored private var turnTask: Task<Void, Never>?

    init(llm: any LLMClient = BackendLLMClient()) {
        self.llm = llm
        listener.onPartial = { [weak self] text in
            self?.liveTranscript = text
        }
        listener.onFinal = { [weak self] text in
            self?.handleUserTurn(text)
        }
        listener.onFailure = { [weak self] message in
            self?.errorMessage = message
            self?.state = .failed
        }
    }

    var primaryActionTitle: String {
        switch state {
        case .listening: "Finish speaking"
        case .thinking, .speaking: "Interrupt and speak"
        case .idle, .failed: "Start speaking"
        }
    }

    var primaryActionSymbol: String {
        switch state {
        case .listening: "stop.fill"
        case .thinking, .speaking: "mic.fill"
        case .idle, .failed: "mic.fill"
        }
    }

    func activatePrimaryAction() async {
        switch state {
        case .listening:
            finishListening()
        case .thinking, .speaking:
            await interruptAndListen()
        case .idle, .failed:
            await startListening()
        }
    }

    func startListening() async {
        errorMessage = nil
        let hasMicrophoneAccess = await AVAudioApplication.requestRecordPermission()
        guard hasMicrophoneAccess else {
            fail("Allow microphone access in Settings to practice speaking.")
            return
        }

        let hasSpeechAccess = await requestSpeechAuthorization()
        guard hasSpeechAccess else {
            fail("Allow speech recognition access in Settings to transcribe your practice.")
            return
        }

        do {
            liveTranscript = ""
            reply = ""
            try listener.start()
            state = .listening
        } catch {
            fail(error.localizedDescription)
        }
    }

    func finishListening() {
        guard state == .listening else { return }
        state = .thinking
        listener.finish()
    }

    func interruptAndListen() async {
        turnTask?.cancel()
        turnTask = nil
        speaker.stopImmediately()
        listener.cancel()
        state = .idle
        await startListening()
    }

    private func handleUserTurn(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fail("I didn’t catch that. Try speaking a little closer to your microphone.")
            return
        }

        turnTask?.cancel()
        state = .thinking
        reply = ""
        errorMessage = nil

        turnTask = Task { [weak self] in
            guard let self else { return }
            await streamCoachReply(for: text)
        }
    }

    private func streamCoachReply(for text: String) async {
        var chunker = SentenceChunker()

        do {
            for try await token in llm.stream(userText: text) {
                try Task.checkCancellation()
                reply += token
                for sentence in chunker.feed(token) {
                    state = .speaking
                    speaker.enqueue(sentence)
                }
            }

            if let remainder = chunker.flush() {
                state = .speaking
                speaker.enqueue(remainder)
            }

            await speaker.waitUntilFinished()
            guard !Task.isCancelled else { return }
            speaker.deactivateAudioSession()
            state = .idle
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            speaker.stopImmediately()
            speaker.deactivateAudioSession()
            errorMessage = error.localizedDescription
            state = .failed
        }
    }

    private func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private func fail(_ message: String) {
        errorMessage = message
        state = .failed
    }
}
