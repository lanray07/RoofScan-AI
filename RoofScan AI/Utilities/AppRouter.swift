import Foundation
import Observation
import SwiftUI

enum AppRoute: Hashable {
    case newInspection
    case inspectionDetail(UUID)
    case photoCapture(UUID)
    case aiScan(UUID)
    case issueReview(UUID)
    case reportGenerator(UUID)
    case savedInspections
    case paywall
    case settings
}

@MainActor
@Observable
final class AppRouter {
    var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func reset() {
        path = NavigationPath()
    }
}
