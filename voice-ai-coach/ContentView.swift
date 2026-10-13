import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.largeTitle)
                .foregroundStyle(.tint)

            Text("Voice AI Coach")
                .font(.title)
                .bold()

            Text(appModel.statusMessage)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
