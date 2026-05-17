import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upgrade RoofScan AI")
                        .font(.largeTitle.weight(.bold))
                    Text("Unlock professional reports, higher scan limits, branding, and contractor-ready workflows.")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 10)

                planCard(
                    plan: .free,
                    features: [
                        "2 inspections per month",
                        "10 photo scans per month",
                        "Basic PDF export",
                        "RoofScan AI footer on reports"
                    ]
                )

                planCard(
                    plan: .proMonthly,
                    features: [
                        "Unlimited inspections",
                        "250 AI photo scans/month",
                        "Custom logo",
                        "Client-ready reports",
                        "Repair priority list",
                        "Before/after comparison"
                    ]
                )

                planCard(
                    plan: .proYearly,
                    features: [
                        "All Pro Monthly features",
                        "Lower annual placeholder price",
                        "Professional PDF exports"
                    ]
                )

                planCard(
                    plan: .businessMonthly,
                    features: [
                        "Unlimited inspections",
                        "Unlimited reports",
                        "Advanced branding",
                        "Insurance documentation template",
                        "Contractor action list export",
                        "Team workflow placeholder"
                    ]
                )

                Button {
                    Task { await subscriptionManager.restorePurchases() }
                } label: {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                if subscriptionManager.usesMockState {
                    Text("Mock subscription mode is enabled for development. Replace product identifiers in App Store Connect and run with real StoreKit products before release.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let error = subscriptionManager.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .background(AppTheme.pageBackground)
        .navigationTitle("Plans")
    }

    private func planCard(plan: SubscriptionPlan, features: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.displayName)
                        .font(.title3.weight(.bold))
                    Text(plan.priceText)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if subscriptionManager.activePlan == plan {
                    Label("Current", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                }
            }

            ForEach(features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark")
                    .font(.subheadline)
            }

            Button {
                Task { await subscriptionManager.purchase(plan) }
            } label: {
                Text(plan == .free ? "Use Free" : "Choose \(plan.displayName)")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(plan == .businessMonthly ? AppTheme.orange : AppTheme.blue)
            .disabled(subscriptionManager.isLoading || subscriptionManager.activePlan == plan)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
