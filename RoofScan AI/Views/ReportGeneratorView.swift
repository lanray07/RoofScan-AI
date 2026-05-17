import SwiftData
import SwiftUI
import UIKit

struct ReportGeneratorView: View {
    let inspectionID: UUID

    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @Environment(\.pdfReportService) private var pdfReportService
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(AppRouter.self) private var router

    @AppStorage("businessName") private var businessName = ""
    @AppStorage("businessContactName") private var businessContactName = ""
    @AppStorage("businessPhone") private var businessPhone = ""
    @AppStorage("businessEmail") private var businessEmail = ""
    @AppStorage("businessLogoBase64") private var businessLogoBase64 = ""

    @Query private var inspections: [RoofInspection]
    @Query(sort: \RoofPhoto.createdAt, order: .forward) private var photos: [RoofPhoto]
    @Query(sort: \RoofIssue.createdAt, order: .reverse) private var issues: [RoofIssue]
    @Query(sort: \RoofReport.createdAt, order: .reverse) private var reports: [RoofReport]

    @State private var viewModel = ReportViewModel()

    private var inspection: RoofInspection? {
        inspections.first { $0.id == inspectionID }
    }

    private var inspectionPhotos: [RoofPhoto] {
        photos.filter { $0.inspectionId == inspectionID }
    }

    private var inspectionIssues: [RoofIssue] {
        issues.filter { $0.inspectionId == inspectionID }
    }

    private var latestReportURL: URL? {
        viewModel.generatedPDFURL ?? reports.first { $0.inspectionId == inspectionID }?.pdfLocalURL
    }

    var body: some View {
        Group {
            if let inspection {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ReportPreviewView(
                            inspection: inspection,
                            issues: inspectionIssues,
                            summary: viewModel.summary,
                            priorityList: viewModel.priorityList
                        )

                        VStack(spacing: 10) {
                            Button {
                                Task {
                                    await viewModel.generateReport(
                                        inspection: inspection,
                                        photos: inspectionPhotos,
                                        issues: inspectionIssues,
                                        businessProfile: businessProfile,
                                        includeBranding: subscriptionManager.canUseProBranding,
                                        includeBusinessBranding: subscriptionManager.canUseBusinessBranding,
                                        aiService: aiService,
                                        pdfService: pdfReportService,
                                        modelContext: modelContext
                                    )
                                }
                            } label: {
                                if viewModel.isGenerating {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Label("Generate PDF Report", systemImage: "doc.richtext")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(AppTheme.blue)
                            .disabled(viewModel.isGenerating)

                            if let latestReportURL {
                                ShareLink(item: latestReportURL) {
                                    Label("Share PDF", systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.orange)
                            }

                            Button {
                                UIPasteboard.general.string = viewModel.generatedReportText.isEmpty ? viewModel.summary : viewModel.generatedReportText
                            } label: {
                                Label("Copy Report Text", systemImage: "doc.on.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.summary.isEmpty)
                        }
                        .padding(14)
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        if !subscriptionManager.canUseProBranding {
                            UpgradeBanner(statusText: "Free reports include the RoofScan AI footer") {
                                router.navigate(to: .paywall)
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                }
                .background(AppTheme.pageBackground)
            } else {
                ContentUnavailableView("Inspection not found", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Report")
    }

    private var businessProfile: BusinessProfile {
        BusinessProfile(
            businessName: businessName,
            contactName: businessContactName,
            phone: businessPhone,
            email: businessEmail,
            logoData: Data(base64Encoded: businessLogoBase64)
        )
    }
}
