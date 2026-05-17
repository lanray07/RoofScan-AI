import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    var confirmationMessage: String?

    func deleteAllLocalData(
        inspections: [RoofInspection],
        photos: [RoofPhoto],
        issues: [RoofIssue],
        reports: [RoofReport],
        subscriptions: [SubscriptionState],
        modelContext: ModelContext
    ) {
        inspections.forEach(modelContext.delete)
        photos.forEach(modelContext.delete)
        issues.forEach(modelContext.delete)
        reports.forEach(modelContext.delete)
        subscriptions.forEach(modelContext.delete)

        do {
            try modelContext.save()
            confirmationMessage = "All local RoofScan AI data has been deleted."
        } catch {
            confirmationMessage = "Unable to delete all local data. \(error.localizedDescription)"
        }
    }
}
