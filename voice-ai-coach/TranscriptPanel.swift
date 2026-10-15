import SwiftUI

struct TranscriptPanel: View {
    let transcript: String
    let reply: String
    let error: String?

    var body: some View {
        if !transcript.isEmpty || !reply.isEmpty || error != nil {
            VStack(alignment: .leading, spacing: 12) {
                if !transcript.isEmpty {
                    TranscriptBlock(title: "YOU", text: transcript)
                }
                if !reply.isEmpty {
                    TranscriptBlock(title: "COACH", text: reply)
                }
                if let error {
                    Label(error, systemImage: "exclamationmark.circle")
                        .font(.callout)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: .rect(cornerRadius: 20))
        }
    }
}

private struct TranscriptBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .tracking(1)
                .foregroundStyle(.secondary)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
