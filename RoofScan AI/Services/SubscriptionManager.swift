import Foundation
import Observation
import StoreKit
import UIKit

@MainActor
@Observable
final class SubscriptionManager {
    var products: [Product] = []
    var activePlan: SubscriptionPlan
    var isActive: Bool
    var renewsAt: Date?
    var isLoading = false
    var errorMessage: String?

    let usesMockState: Bool

    @ObservationIgnored private var updatesTask: Task<Void, Never>?
    @ObservationIgnored private let productIDs = Set([
        "com.roofscanai.pro.monthly",
        "com.roofscanai.pro.yearly",
        "com.roofscanai.business.monthly"
    ])

    init(useMockState: Bool = true) {
        self.usesMockState = useMockState
        self.activePlan = useMockState ? .proMonthly : .free
        self.isActive = useMockState
        self.renewsAt = useMockState ? Calendar.current.date(byAdding: .month, value: 1, to: .now) : nil
    }

    func configure() {
        guard !usesMockState else { return }
        updatesTask?.cancel()
        updatesTask = listenForTransactions()

        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    func loadProducts() async {
        guard !usesMockState else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Array(productIDs))
                .sorted { $0.displayPrice < $1.displayPrice }
        } catch {
            errorMessage = "Unable to load subscriptions. \(error.localizedDescription)"
        }
    }

    func purchase(_ plan: SubscriptionPlan) async {
        errorMessage = nil

        if usesMockState {
            activateMockPlan(plan)
            return
        }

        guard let productID = plan.productID else {
            activePlan = .free
            isActive = false
            renewsAt = nil
            return
        }

        if products.isEmpty {
            await loadProducts()
        }

        guard let product = products.first(where: { $0.id == productID }) else {
            errorMessage = "Subscription product is unavailable. Please check your connection and try again."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                await transaction.finish()
                await refreshEntitlements()
            case .pending:
                errorMessage = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed. \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        if usesMockState {
            activateMockPlan(.proMonthly)
            return
        }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = "Restore failed. \(error.localizedDescription)"
        }
    }

    func activateMockPlan(_ plan: SubscriptionPlan) {
        activePlan = plan
        isActive = plan != .free
        renewsAt = plan == .free ? nil : Calendar.current.date(byAdding: .month, value: plan == .proYearly ? 12 : 1, to: .now)
    }

    func openManageSubscriptions() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        UIApplication.shared.open(url)
    }

    var canUseProBranding: Bool {
        isActive && activePlan != .free
    }

    var canUseBusinessBranding: Bool {
        isActive && activePlan == .businessMonthly
    }

    var statusText: String {
        if isActive {
            if let renewsAt {
                return "\(activePlan.displayName), renews \(renewsAt.roofScanShortDate)"
            }
            return activePlan.displayName
        }
        return "Free plan"
    }

    func displayPrice(for plan: SubscriptionPlan) -> String {
        guard !usesMockState,
              let productID = plan.productID,
              let product = products.first(where: { $0.id == productID }) else {
            return plan.priceText
        }

        return product.displayPrice
    }

    func subscriptionLengthText(for plan: SubscriptionPlan) -> String {
        guard !usesMockState,
              let productID = plan.productID,
              let product = products.first(where: { $0.id == productID }),
              let period = product.subscription?.subscriptionPeriod else {
            return plan.subscriptionLengthText
        }

        return period.roofScanDisplayName
    }

    private func refreshEntitlements() async {
        var bestPlan: SubscriptionPlan = .free
        var bestExpiration: Date?

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result),
                  let plan = SubscriptionPlan.allCases.first(where: { $0.productID == transaction.productID }) else {
                continue
            }

            if plan == .businessMonthly || bestPlan == .free {
                bestPlan = plan
                bestExpiration = transaction.expirationDate
            }
        }

        activePlan = bestPlan
        isActive = bestPlan != .free
        renewsAt = bestExpiration
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                guard let transaction = try? checkVerified(result) else { continue }
                await transaction.finish()
                await refreshEntitlements()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitVerificationError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

private enum StoreKitVerificationError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "The App Store transaction could not be verified."
    }
}

private extension Product.SubscriptionPeriod {
    var roofScanDisplayName: String {
        let unitName: String

        switch unit {
        case .day:
            unitName = "day"
        case .week:
            unitName = "week"
        case .month:
            unitName = "month"
        case .year:
            unitName = "year"
        @unknown default:
            unitName = "period"
        }

        return value == 1 ? "1 \(unitName)" : "\(value) \(unitName)s"
    }
}
