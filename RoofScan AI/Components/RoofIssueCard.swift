import SwiftUI

struct RoofIssueCard: View {
    let issue: RoofIssue
    var showsApproval: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(issue.title)
                        .font(.headline)
                    Text(issue.category.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                SeverityBadge(severity: issue.severity)
            }

            Text(issue.issueDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Label(issue.confidence.confidenceText, systemImage: "gauge")
                Spacer()
                if showsApproval {
                    Label(issue.userApproved ? "Approved" : "Needs review", systemImage: issue.userApproved ? "checkmark.seal.fill" : "exclamationmark.circle")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(issue.suggestedAction)
                .font(.callout)
                .foregroundStyle(.primary)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.fieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}
