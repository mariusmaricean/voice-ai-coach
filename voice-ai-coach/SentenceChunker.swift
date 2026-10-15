import Foundation

struct SentenceChunker {
    private var buffer = ""
    private let terminators: Set<Character> = [".", "!", "?", "\n"]
    private let abbreviations: Set<String> = ["dr.", "mr.", "mrs.", "ms.", "e.g.", "i.e.", "etc."]

    mutating func feed(_ token: String) -> [String] {
        buffer += token
        var sentences: [String] = []
        var cursor = buffer.startIndex

        while cursor < buffer.endIndex {
            let character = buffer[cursor]
            guard terminators.contains(character), isSentenceBoundary(at: cursor) else {
                cursor = buffer.index(after: cursor)
                continue
            }

            let end = buffer.index(after: cursor)
            let sentence = String(buffer[..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
            buffer = String(buffer[end...]).trimmingCharacters(in: .whitespaces)
            cursor = buffer.startIndex
        }

        return sentences
    }

    mutating func flush() -> String? {
        let remainder = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        buffer = ""
        return remainder.isEmpty ? nil : remainder
    }

    private func isSentenceBoundary(at index: String.Index) -> Bool {
        let character = buffer[index]
        let nextIndex = buffer.index(after: index)
        let nextCharacter = nextIndex < buffer.endIndex ? buffer[nextIndex] : nil

        guard nextCharacter?.isWhitespace == true else {
            return false
        }
        guard character == "." else {
            return true
        }

        guard index > buffer.startIndex else { return true }
        let previousIndex = buffer.index(before: index)
        if buffer[previousIndex].isNumber, nextCharacter?.isNumber == true {
            return false
        }

        let precedingText = buffer[..<index]
        let finalWord = precedingText.split(whereSeparator: \.isWhitespace).last.map(String.init) ?? ""
        return !abbreviations.contains((finalWord + ".").lowercased())
    }
}
