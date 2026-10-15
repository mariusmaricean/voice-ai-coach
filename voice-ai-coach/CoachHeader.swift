import SwiftUI

struct CoachHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("VOICE AI COACH")
                    .font(.caption)
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                Text("Speaking practice")
                    .font(.largeTitle)
                    .bold()
            }
            Spacer()
            Image(systemName: "waveform")
                .font(.title2)
                .foregroundStyle(.tint)
                .padding()
                .background(.tint.opacity(0.1), in: .circle)
                .accessibilityHidden(true)
        }
    }
}
