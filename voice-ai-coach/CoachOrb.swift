import SwiftUI

struct CoachOrb: View {
    let state: CoachState

    private var isActive: Bool {
        state == .listening || state == .speaking
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.accentColor.opacity(0.05), Color.accentColor.opacity(0.18)],
                        center: .center,
                        startRadius: 48,
                        endRadius: 132
                    )
                )
                .frame(width: 264, height: 264)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue, .indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 184, height: 184)
                .shadow(color: .blue.opacity(0.25), radius: 28, y: 12)

            Image(systemName: symbolName)
                .font(.system(size: 52, weight: .medium))
                .foregroundStyle(.white)
                .symbolEffect(.pulse, isActive: isActive)
        }
        .frame(height: 264)
    }

    private var symbolName: String {
        switch state {
        case .idle, .failed: "mic"
        case .listening: "waveform"
        case .thinking: "ellipsis"
        case .speaking: "waveform"
        }
    }
}
