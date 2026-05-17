import SwiftUI

struct InspectionCard: View {
    let inspection: RoofInspection
    let issueCount: Int
    let photoCount: Int
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(inspection.clientName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(inspection.propertyAddress)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Text(inspection.status.displayName)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .foregroundStyle(AppTheme.blue)
                        .background(AppTheme.blue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }

                HStack(spacing: 14) {
                    Label(inspection.roofType.displayName, systemImage: "house.lodge")
                    Label("\(photoCount) photos", systemImage: "photo")
                    Label("\(issueCount) issues", systemImage: "exclamationmark.triangle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(inspection.createdAt.roofScanShortDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}
