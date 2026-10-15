import AVFAudio
import Speech

@MainActor
final class SpeechListener {
    var onPartial: ((String) -> Void)?
    var onFinal: ((String) -> Void)?
    var onFailure: ((String) -> Void)?

    private let engine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var tapInstalled = false

    func start() throws {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")), recognizer.isAvailable else {
            throw SpeechListenerError.recognizerUnavailable
        }

        self.recognizer = recognizer
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker])
        try audioSession.setActive(true)

        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        request = recognitionRequest

        let input = engine.inputNode
        input.installTap(onBus: 0, bufferSize: 1_024, format: input.outputFormat(forBus: 0)) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        tapInstalled = true
        engine.prepare()
        try engine.start()

        task = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            let transcription = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal ?? false
            let errorMessage = error?.localizedDescription

            Task { @MainActor [weak self] in
                guard let self else { return }
                if let transcription {
                    if isFinal {
                        self.stopCapture()
                        self.onFinal?(transcription)
                    } else {
                        self.onPartial?(transcription)
                    }
                } else if let errorMessage {
                    self.stopCapture()
                    self.onFailure?(errorMessage)
                }
            }
        }
    }

    func finish() {
        stopCapture()
        request?.endAudio()
    }

    func cancel() {
        stopCapture()
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
    }

    private func stopCapture() {
        if engine.isRunning {
            engine.stop()
        }
        if tapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
    }
}

private enum SpeechListenerError: LocalizedError {
    case recognizerUnavailable

    var errorDescription: String? {
        "Speech recognition is currently unavailable."
    }
}
