import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class RoofScanViewModel {
    var isScanning = false
    var errorMessage: String?
    var lastSummary = ""

    func scan(
        inspection: RoofInspection,
        photos: [RoofPhoto],
        existingIssues: [RoofIssue],
        aiService: any AIService,
        modelContext: ModelContext
    ) async {
        guard !photos.isEmpty else {
            errorMessage = "Add at least one roof photo before running the AI scan."
            return
        }

        isScanning = true
        errorMessage = nil
        defer { isScanning = false }

        do {
            for photo in photos {
                guard !existingIssues.contains(where: { $0.photoId == photo.id }),
                      let imageData = photo.imageData else {
                    continue
                }

                let context = AIPhotoScanContext(
                    roofType: inspection.roofType,
                    inspectionPurpose: inspection.inspectionPurpose,
                    photoLabel: photo.label,
                    userNotes: photo.notes
                )

                let result = try await aiService.scanRoofPhoto(imageData, context: context)
                lastSummary = result.summary

                for detected in result.issues {
                    let issue = RoofIssue(
                        inspectionId: inspection.id,
                        photoId: photo.id,
                        title: detected.title,
                        description: detected.description,
                        category: detected.category,
                        severity: detected.severity,
                        confidence: detected.confidence,
                        suggestedAction: detected.suggestedAction,
                        userApproved: true,
                        resolution: detected.severity == .urgent ? .urgentRepair : .repairSoon
                    )
                    modelContext.insert(issue)
                }
            }

            inspection.status = .scanned
            try modelContext.save()
        } catch {
            errorMessage = "AI scan failed. \(error.localizedDescription)"
        }
    }
}
