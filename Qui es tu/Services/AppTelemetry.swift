import FirebaseAnalytics
import FirebaseCrashlytics
import Foundation

enum QuizTelemetryEvent: Equatable {
    case started(quizID: String, questionCount: Int)
    case completed(quizID: String, questionCount: Int)
    case exited(quizID: String, answeredCount: Int)
}

@MainActor
protocol AppTelemetry {
    func track(_ event: QuizTelemetryEvent)
    func recordQuizLoadingFailure(_ error: Error)
}

struct NoOpTelemetry: AppTelemetry {
    func track(_ event: QuizTelemetryEvent) {}
    func recordQuizLoadingFailure(_ error: Error) {}
}

/// Only quiz identifiers and counts are sent, never answers or personality results.
struct FirebaseTelemetry: AppTelemetry {
    static let analyticsPreference = "privacy.analyticsEnabled"
    static let diagnosticsPreference = "privacy.diagnosticsEnabled"
    static func configureCollection() {
#if DEBUG
        let process = ProcessInfo.processInfo
        let isTesting = process.arguments.contains("-uiTesting")
            || process.environment["XCTestConfigurationFilePath"] != nil
            || NSClassFromString("XCTestCase") != nil
            || process.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        Analytics.setAnalyticsCollectionEnabled(
            !isTesting && process.arguments.contains("-FIRDebugEnabled")
        )
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(
            !isTesting && process.arguments.contains("-CrashlyticsDebugEnabled")
        )
        if !isTesting && process.arguments.contains("-CrashlyticsDebugEnabled")
            && process.arguments.contains("-CrashlyticsTestCrash") {
            // Explicit local verification only; this code is absent from Release builds.
            Task { @MainActor in
                try await Task.sleep(for: .seconds(3))
                fatalError("Crashlytics integration test")
            }
        }
#else
        Analytics.setAnalyticsCollectionEnabled(UserDefaults.standard.bool(forKey: analyticsPreference))
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(UserDefaults.standard.bool(forKey: diagnosticsPreference))
#endif
    }

    func track(_ event: QuizTelemetryEvent) {
        let name: String
        let parameters: [String: Any]
        switch event {
        case let .started(quizID, questionCount):
            name = "quiz_started"
            parameters = ["quiz_id": quizID, "question_count": questionCount]
        case let .completed(quizID, questionCount):
            name = "quiz_completed"
            parameters = ["quiz_id": quizID, "question_count": questionCount]
        case let .exited(quizID, answeredCount):
            name = "quiz_exited"
            parameters = ["quiz_id": quizID, "answered_count": answeredCount]
        }
        Analytics.logEvent(name, parameters: parameters)
    }

    func recordQuizLoadingFailure(_ error: Error) {
        let source = error as NSError
        // Strip backend messages/userInfo, which can contain document data or URLs.
        let sanitized = NSError(domain: source.domain, code: source.code, userInfo: [
            NSLocalizedDescriptionKey: "Quiz catalog could not be loaded."
        ])
        Crashlytics.crashlytics().record(error: sanitized)
    }
}
