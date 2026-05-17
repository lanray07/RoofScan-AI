import SwiftData
import SwiftUI

struct InspectionDetailView: View {
    let inspectionID: UUID

    @Environment(AppRouter.self) private var router

    @Query private var inspections: [RoofInspection]
    @Query(sort: \RoofPhoto.createdAt, order: .forward) private var photos: [RoofPhoto]
    @Query(sort: \RoofIssue.createdAt, order: .reverse) private var issues: [RoofIssue]
    @Query(sort: \RoofReport.createdAt, order: .reverse) private var reports: [RoofReport]

    private var inspection: RoofInspection? {
        inspections.first { $0.id == inspectionID }
    }

    private var inspectionPhotos: [RoofPhoto] {
        photos.filter { $0.inspectionId == inspectionID }
    }

    private var inspectionIssues: [RoofIssue] {
        issues.filter { $0.inspectionId == inspectionID }
    }

    private var inspectionReports: [RoofReport] {
        reports.filter { $0.inspectionId == inspectionID }
    }

    var body: some View {
        Group {
            if let inspection {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(inspection.clientName)
                                .font(.largeTitle.weight(.bold))
                            Text(inspection.propertyAddress)
                                .foregroundStyle(.secondary)
                            HStack {
                                Label(inspection.roofType.displayName, systemImage: "house.lodge")
                                Spacer()
                                Text(inspection.status.displayName)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        actionGrid(for: inspection)

                        section("Photos", count: inspectionPhotos.count) {
                            if inspectionPhotos.isEmpty {
                                EmptyStateView(systemImage: "photo", title: "No photos", message: "Add roof photos before scanning.")
                            } else {
                                ForEach(inspectionPhotos.prefix(3)) { photo in
                                    RoofPhotoCard(photo: photo)
                                }
                            }
                        }

                        section("Findings", count: inspectionIssues.count) {
                            if inspectionIssues.isEmpty {
                                EmptyStateView(systemImage: "exclamationmark.triangle", title: "No findings", message: "Run a mock AI scan or add manual findings.")
                            } else {
                                ForEach(inspectionIssues.prefix(4)) { issue in
                                    RoofIssueCard(issue: issue)
                                }
                            }
                        }

                        section("Reports", count: inspectionReports.count) {
                            if inspectionReports.isEmpty {
                                Text("No reports generated yet.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(inspectionReports) { report in
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
                                    .padding(12)
                                    .background(AppTheme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(AppTheme.pageBackground)
                .navigationTitle("Inspection")
            } else {
                ContentUnavailableView("Inspection not found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private func actionGrid(for inspection: RoofInspection) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            actionButton("Photos", image: "camera") {
                router.navigate(to: .photoCapture(inspection.id))
            }
            actionButton("AI Scan", image: "sparkles") {
                router.navigate(to: .aiScan(inspection.id))
            }
            actionButton("Review", image: "slider.horizontal.3") {
                router.navigate(to: .issueReview(inspection.id))
            }
            actionButton("Report", image: "doc.richtext") {
                router.navigate(to: .reportGenerator(inspection.id))
            }
        }
    }

    private func actionButton(_ title: String, image: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: image)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.blue)
    }

    private func section<Content: View>(_ title: String, count: Int, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            content()
        }
    }
}
