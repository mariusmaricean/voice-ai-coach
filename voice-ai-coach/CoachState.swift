import Foundation

enum CoachState: Equatable {
    case idle
    case listening
    case thinking
    case speaking
    case failed

    var title: String {
        switch self {
        case .idle: "Ready when you are"
        case .listening: "I’m listening"
        case .thinking: "Thinking of a helpful response"
        case .speaking: "Your coach is speaking"
        case .failed: "Let’s try again"
        }
    }

    var subtitle: String {
        switch self {
        case .idle: "Practice a thought, answer, or story out loud."
        case .listening: "Tap Finish speaking when you’re done."
        case .thinking: "Your response is on the way."
        case .speaking: "Tap to interrupt and say something else."
        case .failed: "Check your connection and try again."
        }
    }
}
