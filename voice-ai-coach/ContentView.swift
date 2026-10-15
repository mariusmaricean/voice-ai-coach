import SwiftUI

struct ContentView: View {
    @Environment(VoiceCoach.self) private var coach

    var body: some View {
        VStack(spacing: 0) {
            CoachHeader()
                .padding(.top)

            Spacer(minLength: 32)

            CoachOrb(state: coach.state)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            Text(coach.state.title)
                .font(.title2)
                .bold()
                .padding(.top, 28)

            Text(coach.state.subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            TranscriptPanel(transcript: coach.liveTranscript, reply: coach.reply, error: coach.errorMessage)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 32)

            Spacer(minLength: 24)

            Button {
                Task {
                    await coach.activatePrimaryAction()
                }
            } label: {
                Label(coach.primaryActionTitle, systemImage: coach.primaryActionSymbol)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom)
        }
        .padding(.horizontal)
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }

}

#Preview {
    ContentView()
        .environment(VoiceCoach())
}
