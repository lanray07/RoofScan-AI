import SwiftData
import SwiftUI

struct AIScanOutputView: View {
    let inspectionID: UUID

    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @Environment(AppRouter.self) private var router

    @Query private var inspections: [RoofInspection]
    @Query(sort: \RoofPhoto.createdAt, order: .forward) private var photos: [RoofPhoto]
    @Query(sort: \RoofIssue.createdAt, order: .reverse) private var issues: [RoofIssue]

    @State private var viewModel = RoofScanViewModel()

    private var inspection: RoofInspection? {
        inspections.first { $0.id == inspectionID }
    }

    private var inspectionPhotos: [RoofPhoto] {
        photos.filter { $0.inspectionId == inspectionID }
    }

    private var inspectionIssues: [RoofIssue] {
        issues.filter { $0.inspectionId == inspectionID }
    }

    var body: some View {
        Group {
            if let inspection {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("AI Roof Scan Output")
                                .font(.largeTitle.weight(.bold))
                            Text("Mock AI is enabled by default. Findings are visual suggestions and require professional verification.")
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            Task {
                                await viewModel.scan(
                                    inspection: inspection,
                                    photos: inspectionPhotos,
                                    existingIssues: inspectionIssues,
                                    aiService: aiService,
                                    modelContext: modelContext
                                )
                            }
                        } label: {
                            if viewModel.isScanning {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Label(scanButtonTitle, systemImage: "sparkles")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(AppTheme.blue)
                        .disabled(viewModel.isScanning || inspectionPhotos.isEmpty)

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        if !viewModel.lastSummary.isEmpty {
                            Text(viewModel.lastSummary)
                                .font(.subheadline)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Findings")
                                .font(.title3.weight(.bold))

                            if inspectionIssues.isEmpty {
                                EmptyStateView(systemImage: "sparkles", title: "No findings yet", message: "Run the AI scan to generate editable visual suggestions.")
                            } else {
                                ForEach(inspectionIssues) { issue in
                                    RoofIssueCard(issue: issue)
                                }

                                Button {
                                    router.navigate(to: .issueReview(inspection.id))
                                } label: {
                                    Label("Review and Edit Findings", systemImage: "slider.horizontal.3")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.orange)
                            }
                        }
                    }
                    .padding()
                }
                .background(AppTheme.pageBackground)
            } else {
                ContentUnavailableView("Inspection not found", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("AI Scan")
    }

    private var scanButtonTitle: String {
        inspectionIssues.isEmpty ? "Run AI Roof Scan" : "Scan New Photos"
    }
}
