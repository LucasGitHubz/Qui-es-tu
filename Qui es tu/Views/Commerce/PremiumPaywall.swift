import StoreKit
import SwiftUI

struct PremiumPaywall: View {
    var quiz: Quizz?
    let quizzes: [Quizz]
    var onUnlocked: () -> Void = {}
    @Environment(PurchaseStore.self) private var purchases
    @Environment(\.dismiss) private var dismiss
    @State private var hasFinished = false
    @State private var showsPreviewConfirmation = false

    private var isDebugPreview: Bool {
#if DEBUG
        quiz?.id == DebugCommercePreview.quiz.id
#else
        false
#endif
    }

    private var previewPremiumPrice: String? {
#if DEBUG
        isDebugPreview ? DebugCommercePreview.premiumPrice : nil
#else
        nil
#endif
    }

    private var previewQuizPrice: String? {
#if DEBUG
        isDebugPreview ? DebugCommercePreview.quizPrice : nil
#else
        nil
#endif
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 12) {
                        PaywallHero()
                            .frame(maxHeight: min(280, max(160, geometry.size.height * 0.30)))
                        if isDebugPreview {
                            Text("Mode démo · Aucun paiement réel")
                                .font(.caption.weight(.semibold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 44)
                                .accessibilityIdentifier("paywall.debugNotice")
                        }
                        PaywallBenefits()
                            .padding(.horizontal, 8)

                        Spacer(minLength: 16)

                        PaywallSubscriptionOffer(
                            product: purchases.products[CommerceConfiguration.premiumID],
                            isPremium: !isDebugPreview && purchases.access.isPremium,
                            isLoading: purchases.isLoadingProducts,
                            isBusy: purchases.isBusy,
                            onSubscribe: subscribe,
                            onContinue: finish,
                            previewPrice: previewPremiumPrice
                        )

                        if let quiz, let id = quiz.productID, (isDebugPreview || !purchases.access.canOpen(quiz)) {
                            PaywallQuizOffer(
                                title: quiz.displayTitle,
                                product: purchases.products[id],
                                isBusy: purchases.isBusy,
                                onPurchase: buyQuiz,
                                previewPrice: previewQuizPrice
                            )
                        }

                        PaywallFooter(onRestore: restore, isDebugPreview: isDebugPreview)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, geometry.safeAreaInsets.top + 54)
                    .padding(.bottom, 8)
                    .frame(maxWidth: 560)
                    .frame(minHeight: geometry.size.height, alignment: .top)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea(edges: .top)
            }
            .overlay(alignment: .top) {
                HStack {
                    Spacer()
                    Button("Fermer", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(HomeTheme.settingsInk)
                        .frame(width: 44, height: 44)
                        .background(HomeTheme.surface, in: .circle)
                        .overlay { Circle().strokeBorder(HomeTheme.settingsBorder, lineWidth: 1) }
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
                        .accessibilityIdentifier("paywall.close")
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 4)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .background {
                HomeTheme.background.ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .foregroundStyle(HomeTheme.ink)
        .tint(PaywallTheme.accent)
        .alert("Aperçu du paiement", isPresented: $showsPreviewConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Ceci est une démonstration de l’écran d’achat. Aucun achat n’est lancé et aucun montant ne sera débité.")
        }
        .task { await loadOffer() }
        .onChange(of: purchases.access) { _, _ in finishIfUnlocked() }
    }

    private func loadOffer() async {
        guard !isDebugPreview else { return }
        purchases.message = nil
        PilotTelemetry.event("paywall_viewed", parameters: ["source": quiz?.id ?? "home"])
        await purchases.loadProducts(for: quizzes)
    }

    private func subscribe() {
        guard !isDebugPreview else { showsPreviewConfirmation = true; return }
        guard let product = purchases.products[CommerceConfiguration.premiumID] else { return }
        purchase(product)
    }

    private func buyQuiz() {
        guard !isDebugPreview else { showsPreviewConfirmation = true; return }
        guard let id = quiz?.productID, let product = purchases.products[id] else { return }
        purchase(product)
    }

    private func purchase(_ product: Product) {
        Task {
            await purchases.purchase(product)
            finishIfUnlocked()
        }
    }

    private func restore() {
        guard !isDebugPreview else { return }
        Task {
            await purchases.restore()
            finishIfUnlocked()
        }
    }

    private func finishIfUnlocked() {
        guard !isDebugPreview else { return }
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
