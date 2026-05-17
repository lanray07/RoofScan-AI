import Foundation
import Observation

struct DashboardStats {
    let totalInspections: Int
    let urgentIssues: Int
    let reportsGenerated: Int
    let photosScanned: Int
}

@MainActor
@Observable
final class DashboardViewModel {
    var stats = DashboardStats(totalInspections: 0, urgentIssues: 0, reportsGenerated: 0, photosScanned: 0)

    func refresh(inspections: [RoofInspection], issues: [RoofIssue], reports: [RoofReport], photos: [RoofPhoto]) {
        stats = DashboardStats(
            totalInspections: inspections.count,
            urgentIssues: issues.filter { $0.severity == .urgent && $0.userApproved }.count,
            reportsGenerated: reports.count,
            photosScanned: photos.count
        )
    }

    func recentInspections(from inspections: [RoofInspection]) -> [RoofInspection] {
        Array(inspections.sorted { $0.createdAt > $1.createdAt }.prefix(5))
    }

    func urgentIssues(from issues: [RoofIssue]) -> [RoofIssue] {
        Array(issues.filter { $0.severity == .urgent && $0.userApproved }.prefix(4))
    }
}
