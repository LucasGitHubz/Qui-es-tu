import StoreKit
import SwiftUI

struct PremiumPaywall: View {
    var quiz: Quizz?
    let quizzes: [Quizz]
    var onUnlocked: () -> Void = {}
    @Environment(PurchaseStore.self) private var purchases
    @Environment(\.dismiss) private var dismiss
    @State private var hasFinished = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(AppTheme.coralCTA)
                    Text("Passe à Premium").font(.largeTitle.bold())
                    Text("Tous les quiz, sans publicité.").font(.title2)
                    benefit("Accède à tous les quiz et à un nouveau quiz chaque semaine.", icon: "square.stack.fill")
                    benefit("Profite de l’app sans publicité.", icon: "sparkles")
                    benefit("Soutiens un développeur indépendant qui crée cette app en solo.", icon: "heart.fill")

                    if purchases.access.isPremium {
                        Label("Premium est actif", systemImage: "checkmark.seal.fill")
                        Button("Continuer", action: finish).buttonStyle(.borderedProminent)
                    } else if let premium = purchases.products[CommerceConfiguration.premiumID] {
                        Text("\(premium.displayPrice) / mois").font(.title.bold())
                        Button("Devenir Premium") {
                            Task { await purchases.purchase(premium); finishIfUnlocked() }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(purchases.isBusy || !CommerceConfiguration.purchasesEnabled)
                        .accessibilityIdentifier("paywall.subscribe")
                    } else {
                        Text(purchases.isLoadingProducts ? "Chargement des prix…" : "L’offre Premium sera bientôt disponible.")
                    }

                    Text("Abonnement renouvelé automatiquement. Résiliable à tout moment dans les réglages de l’App Store. Accès Premium jusqu’à la fin de la période payée.")
                        .font(.footnote).foregroundStyle(.secondary)

                    if let quiz, let id = quiz.productID, !purchases.access.canOpen(quiz) {
                        Divider()
                        Text("Seulement ce quiz ?").font(.headline)
                        Text(quiz.displayTitle).font(.title3.bold())
                        Text("Achat unique, accès permanent et replays inclus. Les publicités restent affichées sur l’accueil et les résultats. Seul Premium supprime les publicités.")
                            .font(.subheadline)
                        if let product = purchases.products[id] {
                            Button("Acheter ce quiz · \(product.displayPrice)") {
                                Task { await purchases.purchase(product); finishIfUnlocked() }
                            }
                            .buttonStyle(.bordered)
                            .disabled(purchases.isBusy || !CommerceConfiguration.purchasesEnabled)
                            .accessibilityIdentifier("paywall.buyQuiz")
                        } else {
                            Text("Ce quiz n’est pas encore disponible à l’achat.").font(.footnote)
                        }
                    }

                    if !CommerceConfiguration.purchasesEnabled {
                        Text("Les achats ne sont pas encore ouverts. Les quiz gratuits restent disponibles.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    if purchases.isBusy { ProgressView("Connexion à l’App Store…") }
                    if let message = purchases.message { Text(message).font(.callout).accessibilityIdentifier("paywall.message") }
                    Button("Restaurer mes achats") { Task { await purchases.restore(); finishIfUnlocked() } }
                        .disabled(purchases.isBusy)
                    Link("Gérer mon abonnement", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    Link("Conditions d’utilisation", destination: CommerceConfiguration.termsURL)
                    if let privacy = CommerceConfiguration.privacyURL {
                        Link("Confidentialité", destination: privacy)
                    } else {
                        NavigationLink("Confidentialité") { PrivacyInformationView() }
                    }
                }
                .padding(24)
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.turquoise.opacity(0.08))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Fermer") { dismiss() } }
            }
        }
        .task {
            purchases.message = nil
            PilotTelemetry.event("paywall_viewed", parameters: ["source": quiz?.id ?? "home"])
            await purchases.loadProducts(for: quizzes)
        }
        .onChange(of: purchases.access) { _, _ in finishIfUnlocked() }
    }

    private func benefit(_ text: String, icon: String) -> some View {
        Label { Text(text).fixedSize(horizontal: false, vertical: true) } icon: {
            Image(systemName: icon).foregroundStyle(AppTheme.coralCTA)
        }
    }

    private func finishIfUnlocked() {
        if let quiz, purchases.access.canOpen(quiz) { finish() }
        else if quiz == nil && purchases.access.isPremium { dismiss() }
    }

    private func finish() {
        guard !hasFinished else { return }
        hasFinished = true
        dismiss()
        onUnlocked()
    }
}
