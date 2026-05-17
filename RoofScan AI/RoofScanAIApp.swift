import SwiftData
import SwiftUI

@main
struct RoofScanAIApp: App {
    @State private var subscriptionManager = SubscriptionManager(useMockState: true)

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(subscriptionManager)
                .environment(\.aiService, MockAIService())
                .environment(\.pdfReportService, PDFReportService())
                .task {
                    subscriptionManager.configure()
                }
        }
        .modelContainer(for: [
            RoofInspection.self,
            RoofPhoto.self,
            RoofIssue.self,
            RoofReport.self,
            SubscriptionState.self
        ])
    }
}
