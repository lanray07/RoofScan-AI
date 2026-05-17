import SwiftUI

struct ReportPreviewView: View {
    let inspection: RoofInspection
    let issues: [RoofIssue]
    let summary: String
    let priorityList: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Roofing Inspection Report")
                    .font(.title3.weight(.bold))
                Text(inspection.clientName)
                    .font(.headline)
                Text(inspection.propertyAddress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            previewSection("Summary", text: summary.isEmpty ? "Generate the report to create a professional summary." : summary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Severity Breakdown")
                    .font(.headline)
                ForEach(IssueSeverity.allCases.reversed(), id: \.self) { severity in
                    HStack {
                        SeverityBadge(severity: severity)
                        Text("\(issues.filter { $0.severity == severity && $0.userApproved }.count) item(s)")
                            .font(.subheadline)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Repair Priority List")
                    .font(.headline)
                if priorityList.isEmpty {
                    Text("No repair priorities generated yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(priorityList.enumerated()), id: \.offset) { index, item in
                        Text("\(index + 1). \(item)")
                            .font(.subheadline)
                    }
                }
            }

            previewSection("Disclaimer", text: AppConstants.reportDisclaimer)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func previewSection(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
