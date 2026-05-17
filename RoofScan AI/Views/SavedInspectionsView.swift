import SwiftData
import SwiftUI

struct SavedInspectionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @Query(sort: \RoofInspection.createdAt, order: .reverse) private var inspections: [RoofInspection]
    @Query(sort: \RoofIssue.createdAt, order: .reverse) private var issues: [RoofIssue]
    @Query(sort: \RoofPhoto.createdAt, order: .reverse) private var photos: [RoofPhoto]
    @Query(sort: \RoofReport.createdAt, order: .reverse) private var reports: [RoofReport]

    @State private var searchText = ""
    @State private var severityFilter: IssueSeverity?

    private var filteredInspections: [RoofInspection] {
        inspections.filter { inspection in
            let matchesSearch = searchText.isEmpty || [
                inspection.clientName,
                inspection.propertyAddress,
                inspection.createdAt.roofScanShortDate,
                inspection.roofType.displayName,
                inspection.inspectionPurpose.displayName
            ]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(searchText)

            let matchesSeverity: Bool
            if let severityFilter {
                matchesSeverity = issues.contains {
                    $0.inspectionId == inspection.id && $0.severity == severityFilter
                }
            } else {
                matchesSeverity = true
            }

            return matchesSearch && matchesSeverity
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Severity", selection: $severityFilter) {
                    Text("Any severity").tag(nil as IssueSeverity?)
                    ForEach(IssueSeverity.allCases) { severity in
                        Text(severity.displayName).tag(severity as IssueSeverity?)
                    }
                }
            }

            Section("Saved Inspections") {
                if filteredInspections.isEmpty {
                    EmptyStateView(systemImage: "folder", title: "No saved inspections", message: "Search results and saved inspections will appear here.")
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredInspections) { inspection in
                        InspectionCard(
                            inspection: inspection,
                            issueCount: issueCount(for: inspection.id),
                            photoCount: photoCount(for: inspection.id)
                        ) {
                            router.navigate(to: .inspectionDetail(inspection.id))
                        }
                        .swipeActions {
                            Button {
                                duplicate(inspection)
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            .tint(AppTheme.blue)
                        }
                    }
                }
            }

            Section("Recent Reports") {
                if reports.isEmpty {
                    Text("No saved reports yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(reports.prefix(8)) { report in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(report.title)
                                    .font(.headline)
                                Text(report.createdAt.roofScanShortDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let url = report.pdfLocalURL {
                                ShareLink(item: url) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                }
            }

            Section("Before/After Photos") {
                Label("Comparison workflow placeholder", systemImage: "rectangle.split.2x1")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Saved")
        .searchable(text: $searchText, prompt: "Client, property, date, severity")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .newInspection)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New inspection")
            }
        }
    }

    private func issueCount(for inspectionID: UUID) -> Int {
        issues.filter { $0.inspectionId == inspectionID }.count
    }

    private func photoCount(for inspectionID: UUID) -> Int {
        photos.filter { $0.inspectionId == inspectionID }.count
    }

    private func duplicate(_ inspection: RoofInspection) {
        let copy = RoofInspection(
            propertyAddress: inspection.propertyAddress,
            clientName: "\(inspection.clientName) Copy",
            roofType: inspection.roofType,
            inspectionPurpose: inspection.inspectionPurpose,
            notes: inspection.notes,
            status: .draft
        )
        modelContext.insert(copy)
        try? modelContext.save()
        router.navigate(to: .inspectionDetail(copy.id))
    }
}
