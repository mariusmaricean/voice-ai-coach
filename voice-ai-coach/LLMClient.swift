import Foundation

protocol LLMClient: Sendable {
    func stream(userText: String) -> AsyncThrowingStream<String, Error>
}

struct BackendLLMClient: LLMClient {
    private let streamURL: URL?

    init(streamURL: URL? = nil) {
        if let streamURL {
            self.streamURL = streamURL
        } else {
            let configuredURL = Bundle.main.object(forInfoDictionaryKey: "COACH_STREAM_URL") as? String
            self.streamURL = configuredURL
                .flatMap(URL.init(string:))
                .flatMap { $0.scheme != nil && $0.host != nil ? $0 : nil }
        }
    }

    func stream(userText: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            guard let streamURL else {
                continuation.finish(throwing: LLMClientError.missingConfiguration)
                return
            }

            let requestTask = Task {
                do {
                    var request = URLRequest(url: streamURL)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.httpBody = try JSONEncoder().encode(CoachRequest(text: userText))

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let response = response as? HTTPURLResponse,
                          (200..<300).contains(response.statusCode) else {
                        throw LLMClientError.invalidResponse
                    }

                    for try await line in bytes.lines {
                        try Task.checkCancellation()
                        guard line.hasPrefix("data:") else { continue }
                        let payload = line.dropFirst("data:".count)
                            .trimmingCharacters(in: .whitespaces)
                        guard !payload.isEmpty else { continue }
                        if payload == "[DONE]" { break }

                        let event = try JSONDecoder().decode(CoachStreamEvent.self, from: Data(payload.utf8))
                        if let error = event.error {
                            throw LLMClientError.backend(error)
                        }
                        if let delta = event.delta {
                            continuation.yield(delta)
                        }
                    }

                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish(throwing: CancellationError())
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                requestTask.cancel()
            }
        }
    }
}

private struct CoachRequest: Encodable {
    let text: String
}

private struct CoachStreamEvent: Decodable {
    let delta: String?
    let error: String?
}

private enum LLMClientError: LocalizedError {
    case missingConfiguration
    case invalidResponse
    case backend(String)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            "Add COACH_STREAM_URL to Config/Secrets.xcconfig to connect your coaching backend."
        case .invalidResponse:
            "The coaching service returned an invalid response."
        case .backend(let message):
            message
        }
    }
}
