import Foundation

struct PaidQuizService {
    func fetch(_ quiz: Quizz, proof: String) async throws -> Quizz {
        guard let url = CommerceConfiguration.paidContentURL else { throw PaidQuizError.unavailable }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(Payload(quizID: quiz.id, signedTransaction: proof))
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw PaidQuizError.unavailable }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let content = try decoder.decode(Quizz.self, from: data)
        guard content.id == quiz.id, content.productID == quiz.productID,
              content.questions?.isEmpty == false else { throw PaidQuizError.unavailable }
        return content
    }

    private struct Payload: Encodable {
        let quizID: String
        let signedTransaction: String
    }

    enum PaidQuizError: LocalizedError {
        case unavailable
        var errorDescription: String? { "Ce quiz n’a pas pu être chargé. Vérifie ta connexion ou restaure tes achats." }
    }
}
