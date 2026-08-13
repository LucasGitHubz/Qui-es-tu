import Foundation

enum QuizMatcher {
    static func bestMatch(
        userAnswers: [Int],
        matchingResults: [String: [Int]],
        resultDescriptions: [String: String]
    ) -> QuizResult? {
        let rankedMatches = matchingResults.map { name, answers in
            let matchCount = zip(userAnswers, answers).reduce(into: 0) { count, pair in
                if pair.0 == pair.1 {
                    count += 1
                }
            }
            return (name: name, matchCount: matchCount)
        }
        .sorted {
            if $0.matchCount == $1.matchCount {
                $0.name < $1.name
            } else {
                $0.matchCount > $1.matchCount
            }
        }

        guard let bestMatch = rankedMatches.first else {
            return nil
        }

        return QuizResult(
            name: bestMatch.name,
            description: resultDescriptions[bestMatch.name] ?? "Description unavailable."
        )
    }
}
