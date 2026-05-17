import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ReportViewModel {
    var isGenerating = false
    var errorMessage: String?
    var summary = ""
    var priorityList: [String] = []
    var generatedPDFURL: URL?
    var generatedReportText = ""

    func generateReport(
        inspection: RoofInspection,
        photos: [RoofPhoto],
        issues: [RoofIssue],
        businessProfile: BusinessProfile,
        includeBranding: Bool,
        includeBusinessBranding: Bool,
        aiService: any AIService,
        pdfService: any PDFReportGenerating,
        modelContext: ModelContext
    ) async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            summary = try await aiService.generateInspectionSummary(inspection: inspection, issues: issues)
            priorityList = try await aiService.generateRepairPriorityList(issues: issues)
            generatedReportText = try await aiService.generateReportText(inspection: inspection, issues: issues, summary: summary)

            let payload = PDFReportPayload(
                inspection: inspection,
                photos: photos,
                issues: issues,
                summary: summary,
                priorityList: priorityList,
                businessProfile: businessProfile,
                includeBranding: includeBranding,
                includeBusinessBranding: includeBusinessBranding
            )

            let url = try await pdfService.generatePDF(payload: payload)
            generatedPDFURL = url

            let report = RoofReport(
                inspectionId: inspection.id,
                title: "Roof report - \(inspection.clientName)",
                summary: summary,
                pdfLocalURL: url
            )

            modelContext.insert(report)
            inspection.status = .reportGenerated
            try modelContext.save()
        } catch {
            errorMessage = "Report generation failed. \(error.localizedDescription)"
        }
    }
}
