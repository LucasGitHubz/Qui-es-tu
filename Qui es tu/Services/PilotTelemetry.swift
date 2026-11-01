import FirebaseAnalytics
import FirebaseCore
import Foundation

enum PilotTelemetry {
    static func event(_ name: String, parameters: [String: Any] = [:]) {
        guard !CommerceConfiguration.isPreviewOrTest, FirebaseApp.app() != nil else { return }
        Analytics.logEvent(name, parameters: parameters)
    }

    static func recordWeeklyVisit() {
        let defaults = UserDefaults.standard
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let week = "\(components.yearForWeekOfYear ?? 0)-\(components.weekOfYear ?? 0)"
        guard defaults.string(forKey: "pilot.lastVisitWeek") != week else { return }
        event("weekly_visit", parameters: ["returning": defaults.string(forKey: "pilot.lastVisitWeek") != nil ? 1 : 0])
        defaults.set(week, forKey: "pilot.lastVisitWeek")
    }
}
