import AVFAudio

@MainActor
final class SpeechSpeaker {
    private let synthesizer = AVSpeechSynthesizer()

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }

    func enqueue(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }

    func stopImmediately() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func waitUntilFinished() async {
        while synthesizer.isSpeaking || synthesizer.isPaused {
            do {
                try await Task.sleep(for: .milliseconds(80))
            } catch {
                return
            }
        }
    }
}
