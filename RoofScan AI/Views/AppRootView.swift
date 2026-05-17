import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var dashboardRouter = AppRouter()
    @State private var savedRouter = AppRouter()
    @State private var settingsRouter = AppRouter()

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                TabView {
                    RouterStack(router: dashboardRouter) {
                        DashboardView()
                    }
                    .tabItem {
                        Label("Dashboard", systemImage: "square.grid.2x2")
                    }

                    RouterStack(router: savedRouter) {
                        SavedInspectionsView()
                    }
                    .tabItem {
                        Label("Saved", systemImage: "folder")
                    }

                    RouterStack(router: settingsRouter) {
                        SettingsView()
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                }
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

private struct RouterStack<Content: View>: View {
    @Bindable var router: AppRouter
    let content: Content

    init(router: AppRouter, @ViewBuilder content: () -> Content) {
        self.router = router
        self.content = content()
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .withAppDestinations()
        }
        .environment(router)
    }
}

private extension View {
    func withAppDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .newInspection:
                NewInspectionView()
            case .inspectionDetail(let id):
                InspectionDetailView(inspectionID: id)
            case .photoCapture(let id):
                PhotoCaptureView(inspectionID: id)
            case .aiScan(let id):
                AIScanOutputView(inspectionID: id)
            case .issueReview(let id):
                IssueReviewView(inspectionID: id)
            case .reportGenerator(let id):
                ReportGeneratorView(inspectionID: id)
            case .savedInspections:
                SavedInspectionsView()
            case .paywall:
                PaywallView()
            case .settings:
                SettingsView()
            }
        }
    }
}
