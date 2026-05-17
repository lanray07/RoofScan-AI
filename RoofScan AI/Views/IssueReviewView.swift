import SwiftData
import SwiftUI

struct IssueReviewView: View {
    let inspectionID: UUID

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @Query private var inspections: [RoofInspection]
    @Query(sort: \RoofIssue.createdAt, order: .reverse) private var issues: [RoofIssue]

    private var inspection: RoofInspection? {
        inspections.first { $0.id == inspectionID }
    }

    private var inspectionIssues: [RoofIssue] {
        issues.filter { $0.inspectionId == inspectionID }
    }

    var body: some View {
        Group {
            if let inspection {
                List {
                    Section {
                        Text("Edit AI findings, delete incorrect results, add manual issues, and approve only the items you want in the report.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Section("Findings") {
                        if inspectionIssues.isEmpty {
                            EmptyStateView(systemImage: "exclamationmark.bubble", title: "No issues yet", message: "Add a manual finding or return to the AI scan.")
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(inspectionIssues) { issue in
                                NavigationLink {
                                    IssueEditorView(issue: issue)
                                } label: {
                                    IssueReviewRow(issue: issue)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        delete(issue)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }

                    Section {
                        Button {
                            addManualIssue()
                        } label: {
                            Label("Add Manual Issue", systemImage: "plus.circle")
                        }

                        Button {
                            inspection.status = .reviewed
                            try? modelContext.save()
                            router.navigate(to: .reportGenerator(inspection.id))
                        } label: {
                            Label("Generate Report", systemImage: "doc.richtext")
                        }
                        .disabled(inspectionIssues.isEmpty)
                    }
                }
                .navigationTitle("Issue Review")
            } else {
                ContentUnavailableView("Inspection not found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private func addManualIssue() {
        let issue = RoofIssue(
            inspectionId: inspectionID,
            title: "Manual visual issue",
            description: "Describe the visible roofing issue and any supporting context.",
            category: .generalWear,
            severity: .medium,
            confidence: 1,
            suggestedAction: "Verify on site and update the recommended action.",
            userApproved: true,
            resolution: .repairSoon
        )
        modelContext.insert(issue)
        try? modelContext.save()
    }

    private func delete(_ issue: RoofIssue) {
        modelContext.delete(issue)
        try? modelContext.save()
    }
}

private struct IssueReviewRow: View {
    let issue: RoofIssue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(issue.title)
                    .font(.headline)
                Spacer()
                SeverityBadge(severity: issue.severity)
            }
            Text(issue.category.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
            Label(issue.userApproved ? "Approved for report" : "Excluded from report", systemImage: issue.userApproved ? "checkmark.circle.fill" : "xmark.circle")
                .font(.caption)
                .foregroundStyle(issue.userApproved ? .green : .secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct IssueEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var issue: RoofIssue

    var body: some View {
        Form {
            Section("Finding") {
                TextField("Issue title", text: $issue.title)
                TextField("Description", text: $issue.issueDescription, axis: .vertical)
                    .lineLimit(4...8)
            }

            Section("Classification") {
                Picker("Severity", selection: Binding(get: { issue.severity }, set: { issue.severity = $0 })) {
                    ForEach(IssueSeverity.allCases) { severity in
                        Text(severity.displayName).tag(severity)
                    }
                }

                Picker("Category", selection: Binding(get: { issue.category }, set: { issue.category = $0 })) {
                    ForEach(IssueCategory.allCases) { category in
                        Text(category.displayName).tag(category)
                    }
                }

                Picker("Action", selection: Binding(get: { issue.resolution }, set: { issue.resolution = $0 })) {
                    ForEach(IssueResolution.allCases) { resolution in
                        Text(resolution.displayName).tag(resolution)
                    }
                }
            }

            Section("Report") {
                TextField("Suggested next action", text: $issue.suggestedAction, axis: .vertical)
                    .lineLimit(3...6)

                Slider(value: $issue.confidence, in: 0...1) {
                    Text("Confidence")
                } minimumValueLabel: {
                    Text("0%")
                } maximumValueLabel: {
                    Text("100%")
                }

                Toggle("Approve for report", isOn: $issue.userApproved)
            }
        }
        .navigationTitle("Edit Finding")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    try? modelContext.save()
                }
            }
        }
    }
}
