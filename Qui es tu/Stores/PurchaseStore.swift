import Foundation
import Observation
import StoreKit

@MainActor @Observable
final class PurchaseStore {
    private(set) var access = QuizAccess()
    private(set) var products: [String: Product] = [:]
    private(set) var isBusy = false
    private(set) var isLoadingProducts = false
    var message: String?
    @ObservationIgnored private var proofs: [String: String] = [:]
    @ObservationIgnored private var refreshGeneration = 0
    @ObservationIgnored private let storeKitEnabled: Bool
    @ObservationIgnored private let readEntitlements: @MainActor () async -> (access: QuizAccess, proofs: [String: String])

    init(
        storeKitEnabled: Bool = !CommerceConfiguration.isPreviewOrTest,
        readEntitlements: (@MainActor () async -> (access: QuizAccess, proofs: [String: String]))? = nil
    ) {
        self.storeKitEnabled = storeKitEnabled
        self.readEntitlements = readEntitlements ?? Self.currentEntitlements
    }

    /// The root view owns this structured lifetime task; cancellation stops observation.
    func observeTransactions() async {
        guard storeKitEnabled else {
            access = QuizAccess(isResolved: true)
            return
        }
        await refreshEntitlements()
        for await update in Transaction.updates {
            guard !Task.isCancelled else { return }
            if case .verified(let transaction) = update {
                await refreshEntitlements()
                await transaction.finish()
            }
        }
    }

    func refreshEntitlements() async {
        guard storeKitEnabled else { return }
        refreshGeneration += 1
        let generation = refreshGeneration
        // Keep the last verified snapshot visible until its replacement is ready.
        let snapshot = await readEntitlements()
        guard generation == refreshGeneration, !Task.isCancelled else { return }
        proofs = snapshot.proofs
        access = snapshot.access
        if !snapshot.access.isResolved { message = "Tes achats n’ont pas pu être vérifiés. Essaie de les restaurer." }
    }

    private static func currentEntitlements() async -> (access: QuizAccess, proofs: [String: String]) {
        var ids: Set<String> = []
        var verifiedProofs: [String: String] = [:]
        var verificationFailed = false
        // StoreKit includes subscriptions in billing grace and excludes revoked purchases.
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                verificationFailed = true
                continue
            }
            guard transaction.revocationDate == nil, !transaction.isUpgraded,
                  transaction.productType == .nonConsumable || transaction.productType == .autoRenewable else { continue }
            ids.insert(transaction.productID)
            verifiedProofs[transaction.productID] = result.jwsRepresentation
        }
        return (QuizAccess(isResolved: !verificationFailed, productIDs: ids), verifiedProofs)
    }

    func loadProducts(for quizzes: [Quizz]) async {
        guard !isLoadingProducts, storeKitEnabled else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let ids = Set(quizzes.compactMap(\.productID)).union([CommerceConfiguration.premiumID])
            let loaded = try await Product.products(for: ids)
            products = Dictionary(uniqueKeysWithValues: loaded.filter {
                if $0.id == CommerceConfiguration.premiumID {
                    return $0.type == .autoRenewable
                        && $0.subscription?.subscriptionPeriod.unit == .month
                        && $0.subscription?.subscriptionPeriod.value == 1
                }
                return $0.type == .nonConsumable
            }.map { ($0.id, $0) })
        } catch {
            message = "Les prix sont indisponibles pour le moment. Réessaie dans un instant."
        }
    }

    func purchase(_ product: Product) async {
        guard !isBusy, CommerceConfiguration.purchasesEnabled else { return }
        isBusy = true
        message = nil
        defer { isBusy = false }
        do {
            switch try await product.purchase() {
            case .success(let result):
                guard case .verified(let transaction) = result else {
                    message = "Cet achat n’a pas pu être vérifié. Essaie de restaurer tes achats."
                    return
                }
                await refreshEntitlements()
                await transaction.finish()
                PilotTelemetry.event("purchase_verified", parameters: ["product_id": product.id])
            case .pending:
                message = "Ton achat est en attente de validation par l’App Store."
            case .userCancelled: break
            @unknown default:
                message = "L’achat n’a pas abouti. Réessaie plus tard."
            }
        } catch {
            message = "L’achat n’a pas abouti. Aucun accès n’a été modifié. Tu peux réessayer."
        }
    }

    func restore() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            message = access.productIDs.isEmpty ? "Aucun achat à restaurer sur ce compte App Store." : "Tes achats ont été restaurés."
        } catch {
            message = "La restauration est indisponible. Vérifie ta connexion et réessaie."
        }
    }

    func proof(for quiz: Quizz) -> String? {
        if let productID = quiz.productID, let proof = proofs[productID] { return proof }
        return proofs[CommerceConfiguration.premiumID]
    }
}
