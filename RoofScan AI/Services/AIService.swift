import Foundation

struct AIPhotoScanContext {
    let roofType: RoofType
    let inspectionPurpose: InspectionPurpose
    let photoLabel: PhotoLabel
    let userNotes: String
}

struct AIDetectedIssue: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: IssueCategory
    let severity: IssueSeverity
    let confidence: Double
    let suggestedAction: String
}

struct AIPhotoScanResult {
    let issues: [AIDetectedIssue]
    let summary: String
}

protocol AIService {
    func scanRoofPhoto(_ imageData: Data, context: AIPhotoScanContext) async throws -> AIPhotoScanResult
    func generateInspectionSummary(inspection: RoofInspection, issues: [RoofIssue]) async throws -> String
    func generateRepairPriorityList(issues: [RoofIssue]) async throws -> [String]
    func generateReportText(inspection: RoofInspection, issues: [RoofIssue], summary: String) async throws -> String
}

enum AIServiceError: LocalizedError {
    case invalidResponse
    case backendNotConfigured

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "The AI service returned an invalid response."
        case .backendNotConfigured:
            "Configure your secure backend endpoint before using remote AI mode."
        }
    }
}

extension IssueCategory {
    init(remoteValue: String) {
        let normalised = remoteValue
            .lowercased()
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")

        if normalised.contains("tile") {
            self = .missingBrokenTiles
        } else if normalised.contains("slate") {
            self = .crackedSlate
        } else if normalised.contains("shingle") {
            self = .damagedShingles
        } else if normalised.contains("moss") || normalised.contains("algae") {
            self = .mossAlgaeBuildup
        } else if normalised.contains("gutter") {
            self = .gutterBlockage
        } else if normalised.contains("flashing") {
            self = .flashingConcern
        } else if normalised.contains("chimney") {
            self = .chimneyConcern
        } else if normalised.contains("leak") {
            self = .visibleLeakIndicator
        } else if normalised.contains("pool") || normalised.contains("pond") {
            self = .flatRoofPooling
        } else if normalised.contains("membrane") {
            self = .membraneDamage
        } else if normalised.contains("sag") || normalised.contains("structural") {
            self = .saggingStructuralVisualConcern
        } else if normalised.contains("storm") || normalised.contains("hail") || normalised.contains("wind") {
            self = .stormHailWindDamage
        } else {
            self = .generalWear
        }
    }
}

extension IssueSeverity {
    init(remoteValue: String) {
        switch remoteValue.lowercased() {
        case "urgent":
            self = .urgent
        case "high":
            self = .high
        case "medium":
            self = .medium
        default:
            self = .low
        }
    }
}
