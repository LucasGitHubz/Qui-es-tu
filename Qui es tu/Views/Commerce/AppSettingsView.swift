import SwiftUI

struct AppSettingsView: View {
    @Environment(PurchaseStore.self) private var purchases
    @Environment(AdvertisingStore.self) private var advertising
    @Environment(ReleaseNotificationStore.self) private var notifications
    @Environment(ResultHistoryStore.self) private var history
    @Environment(\.dismiss) private var dismiss
    @State private var confirmsHistoryDeletion = false
    @AppStorage(FirebaseTelemetry.analyticsPreference) private var analyticsEnabled = false
    @AppStorage(FirebaseTelemetry.diagnosticsPreference) private var diagnosticsEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Nouveaux quiz") {
                    Toggle("Me prévenir des sorties", isOn: Binding(
                        get: { notifications.enabled },
                        set: { value in Task { await notifications.setEnabled(value) } }
                    )).disabled(notifications.isBusy)
                    Text("Une alerte à la sortie d’un nouveau quiz, qui peut être payant. Désactivable à tout moment.")
                        .font(.footnote)
                    if notifications.authorizationDenied {
                        Link("Ouvrir les réglages de l’iPhone", destination: URL(string: UIApplication.openSettingsURLString)!)
                    }
                    if let message = notifications.message { Text(message).font(.footnote) }
                }
                Section("Achats") {
                    Label(purchases.access.isPremium ? "Premium actif · sans publicité" : "Version avec publicités", systemImage: "sparkles")
                    Button("Restaurer mes achats") { Task { await purchases.restore() } }.disabled(purchases.isBusy)
                    Link("Gérer mon abonnement", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    if let message = purchases.message { Text(message).font(.footnote) }
                }
                Section("Mes portraits sur cet appareil") {
                    NavigationLink("Historique (\(history.results.count))") {
                        List(history.results) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(result.quizTitle).font(.caption).foregroundStyle(.secondary)
                                Text(result.name).font(.headline)
                                Text(result.description)
                                Text(result.completedAt, style: .date).font(.caption)
                            }
                        }.navigationTitle("Mes portraits")
                    }
                    Button("Effacer mon historique", role: .destructive) { confirmsHistoryDeletion = true }
                        .disabled(history.results.isEmpty)
                }
                Section("Confidentialité") {
                    Toggle("Partager des statistiques d’utilisation", isOn: $analyticsEnabled)
                    Toggle("Envoyer des rapports de plantage", isOn: $diagnosticsEnabled)
                    Text("Facultatif. Google Firebase traite des identifiants techniques et des informations sur l’appareil pour améliorer l’app. Tes réponses et tes portraits ne sont pas envoyés. Tu peux retirer ton accord ici à tout moment.")
                        .font(.footnote)
                    if advertising.isPrivacyOptionsRequired {
                        Button("Préférences publicitaires") { Task { await advertising.showPrivacyOptions() } }
                    }
                    if let message = advertising.message { Text(message).font(.footnote) }
                    if let privacy = CommerceConfiguration.privacyURL {
                        Link("Politique de confidentialité", destination: privacy)
                    } else {
                        NavigationLink("Confidentialité") { PrivacyInformationView() }
                    }
                    Link("Conditions d’utilisation", destination: CommerceConfiguration.termsURL)
                }
            }
            .navigationTitle("Réglages")
            .onChange(of: analyticsEnabled) { _, _ in FirebaseTelemetry.configureCollection() }
            .onChange(of: diagnosticsEnabled) { _, _ in FirebaseTelemetry.configureCollection() }
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Terminé") { dismiss() } } }
            .confirmationDialog("Effacer les portraits enregistrés sur cet appareil ?", isPresented: $confirmsHistoryDeletion) {
                Button("Effacer l’historique", role: .destructive) { history.clear() }
            }
        }
    }
}
