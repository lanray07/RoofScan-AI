import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @Query(sort: \RoofInspection.createdAt, order: .reverse) private var inspections: [RoofInspection]
    @Query(sort: \RoofIssue.createdAt, order: .reverse) private var issues: [RoofIssue]
    @Query(sort: \RoofReport.createdAt, order: .reverse) private var reports: [RoofReport]
    @Query(sort: \RoofPhoto.createdAt, order: .reverse) private var photos: [RoofPhoto]

    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Button {
                    router.navigate(to: .newInspection)
                } label: {
                    Label("New Roof Inspection", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(AppTheme.blue)

                UpgradeBanner(statusText: subscriptionManager.statusText) {
                    router.navigate(to: .paywall)
                }

                statsGrid

                recentInspections
                recentReports
                urgentIssues
            }
            .padding()
        }
        .background(AppTheme.pageBackground)
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .settings)
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .onAppear(perform: refreshStats)
        .onChange(of: inspections.count) { _, _ in refreshStats() }
        .onChange(of: issues.count) { _, _ in refreshStats() }
        .onChange(of: reports.count) { _, _ in refreshStats() }
        .onChange(of: photos.count) { _, _ in refreshStats() }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statTile("Total inspections", value: "\(viewModel.stats.totalInspections)", image: "doc.text.magnifyingglass")
            statTile("Urgent issues", value: "\(viewModel.stats.urgentIssues)", image: "exclamationmark.triangle.fill", tint: .red)
            statTile("Reports generated", value: "\(viewModel.stats.reportsGenerated)", image: "doc.richtext")
            statTile("Photos scanned", value: "\(viewModel.stats.photosScanned)", image: "camera.metering.matrix")
        }
    }

    private var recentInspections: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Recent Inspections") {
                router.navigate(to: .savedInspections)
            }

            if inspections.isEmpty {
                EmptyStateView(systemImage: "house.lodge", title: "No inspections yet", message: "Create your first roof inspection to begin capturing evidence.")
            } else {
                ForEach(viewModel.recentInspections(from: inspections)) { inspection in
                    InspectionCard(
                        inspection: inspection,
                        issueCount: issueCount(for: inspection.id),
                        photoCount: photoCount(for: inspection.id)
                    ) {
                        router.navigate(to: .inspectionDetail(inspection.id))
                    }
                }
            }
        }
    }

    private var recentReports: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Reports")
                .font(.title3.weight(.bold))

            if reports.isEmpty {
                EmptyStateView(systemImage: "doc", title: "No reports generated", message: "Reviewed inspections can be exported as client-ready PDF reports.")
            } else {
                ForEach(reports.prefix(3)) { report in
                    HStack {
                        Image(systemName: "doc.richtext")
                            .foregroundStyle(AppTheme.blue)
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
                            .accessibilityLabel("Share report")
                        }
                    }
                    .padding(14)
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    private var urgentIssues: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Urgent Issues")
                .font(.title3.weight(.bold))

            let urgent = viewModel.urgentIssues(from: issues)
            if urgent.isEmpty {
                EmptyStateView(systemImage: "checkmark.shield", title: "No urgent issues", message: "Urgent findings will appear here after review.")
            } else {
                ForEach(urgent) { issue in
                    RoofIssueCard(issue: issue)
                }
            }
        }
    }

    private func statTile(_ title: String, value: String, image: String, tint: Color = AppTheme.blue) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: image)
                .font(.title2)
                .foregroundStyle(tint)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func sectionHeader(_ title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
            Spacer()
            Button("View all", action: action)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func refreshStats() {
        viewModel.refresh(inspections: inspections, issues: issues, reports: reports, photos: photos)
    }

    private func issueCount(for inspectionID: UUID) -> Int {
        issues.filter { $0.inspectionId == inspectionID }.count
    }

    private func photoCount(for inspectionID: UUID) -> Int {
        photos.filter { $0.inspectionId == inspectionID }.count
    }
}
