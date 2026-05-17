import SwiftUI

struct SeverityBadge: View {
    let severity: IssueSeverity

    var body: some View {
        Text(severity.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .foregroundStyle(.white)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .accessibilityLabel("Severity \(severity.displayName)")
    }

    private var color: Color {
        switch severity {
        case .low: .green
        case .medium: .yellow.opacity(0.9)
        case .high: AppTheme.orange
        case .urgent: .red
        }
    }
}
