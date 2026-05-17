import SwiftUI

struct UpgradeBanner: View {
    let statusText: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.shield")
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.orange)
                .frame(width: 38, height: 38)
                .background(AppTheme.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text("Subscription")
                    .font(.headline)
                Text(statusText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Upgrade", action: action)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.blue)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
