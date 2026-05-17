import Foundation

struct MockAIService: AIService {
    func scanRoofPhoto(_ imageData: Data, context: AIPhotoScanContext) async throws -> AIPhotoScanResult {
        try await Task.sleep(for: .milliseconds(600))

        let primaryIssue = issue(for: context)
        let secondaryIssue = AIDetectedIssue(
            title: "Possible general roof wear",
            description: "The photo appears to show visible ageing or surface variation. This is a non-diagnostic observation and should be checked on site.",
            category: .generalWear,
            severity: .low,
            confidence: 0.58,
            suggestedAction: "Record the condition, monitor during future inspections, and verify during a professional roof survey."
        )

        return AIPhotoScanResult(
            issues: [primaryIssue, secondaryIssue],
            summary: "Mock scan completed for \(context.photoLabel.displayName.lowercased()). Findings use cautious visual language and require professional review."
        )
    }

    func generateInspectionSummary(inspection: RoofInspection, issues: [RoofIssue]) async throws -> String {
        try await Task.sleep(for: .milliseconds(250))

        let urgentCount = issues.filter { $0.severity == .urgent }.count
        let highCount = issues.filter { $0.severity == .high }.count
        let approvedCount = issues.filter(\.userApproved).count

        return """
        RoofScan AI reviewed the available roof photos for \(inspection.propertyAddress). The report includes \(approvedCount) user-approved visual finding(s). \(urgentCount) urgent and \(highCount) high-severity item(s) should be prioritised for professional review. These findings are suggestions only and do not replace a certified inspection.
        """
    }

    func generateRepairPriorityList(issues: [RoofIssue]) async throws -> [String] {
        try await Task.sleep(for: .milliseconds(200))

        return issues
            .filter(\.userApproved)
            .sorted { $0.severity > $1.severity }
            .map { "\($0.severity.displayName): \($0.title) - \($0.suggestedAction)" }
    }

    func generateReportText(inspection: RoofInspection, issues: [RoofIssue], summary: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(200))

        let approvedIssues = issues.filter(\.userApproved)
        let issueText = approvedIssues.map { issue in
            "- \(issue.title): \(issue.issueDescription) Suggested action: \(issue.suggestedAction)"
        }.joined(separator: "\n")

        return """
        Roof inspection report for \(inspection.clientName)

        Property: \(inspection.propertyAddress)
        Purpose: \(inspection.inspectionPurpose.displayName)
        Roof type: \(inspection.roofType.displayName)

        Summary:
        \(summary)

        Findings:
        \(issueText.isEmpty ? "No user-approved findings have been added." : issueText)

        Disclaimer:
        \(AppConstants.reportDisclaimer)
        """
    }

    private func issue(for context: AIPhotoScanContext) -> AIDetectedIssue {
        switch context.photoLabel {
        case .gutter:
            AIDetectedIssue(
                title: "Possible gutter blockage",
                description: "The image appears to show debris or dark buildup around the gutter line that may restrict drainage.",
                category: .gutterBlockage,
                severity: .medium,
                confidence: 0.74,
                suggestedAction: "Recommend safe ground-level review and professional clearing if blockage is confirmed."
            )
        case .chimney:
            AIDetectedIssue(
                title: "Possible chimney flashing concern",
                description: "There is a visible sign around the chimney junction that may indicate flashing movement or weathering.",
                category: .flashingConcern,
                severity: .high,
                confidence: 0.69,
                suggestedAction: "Recommend professional inspection before further weather exposure."
            )
        case .flatRoofSurface:
            AIDetectedIssue(
                title: "Possible flat roof pooling",
                description: "The image appears to show surface discolouration or low spots where water may collect.",
                category: .flatRoofPooling,
                severity: .medium,
                confidence: 0.66,
                suggestedAction: "Check drainage routes and request a qualified flat-roof survey if pooling persists."
            )
        case .interiorLeakEvidence:
            AIDetectedIssue(
                title: "Visible leak indicator",
                description: "The photo appears to show staining or marks that may be consistent with moisture ingress.",
                category: .visibleLeakIndicator,
                severity: .urgent,
                confidence: 0.71,
                suggestedAction: "Recommend immediate professional investigation to locate and resolve the moisture source."
            )
        case .ridge, .valley, .flashing:
            AIDetectedIssue(
                title: "Possible junction wear",
                description: "The roof junction appears to show visible wear that should be checked for water-shedding performance.",
                category: .flashingConcern,
                severity: .high,
                confidence: 0.65,
                suggestedAction: "Prioritise a professional survey of this junction and surrounding roof coverings."
            )
        default:
            AIDetectedIssue(
                title: "Possible damaged roof covering",
                description: "The image appears to show a visible irregularity in the roof covering. This may require closer on-site verification.",
                category: context.roofType == .slate ? .crackedSlate : .missingBrokenTiles,
                severity: context.inspectionPurpose == .stormDamage ? .high : .medium,
                confidence: 0.68,
                suggestedAction: "Recommend professional inspection and repair planning if damage is confirmed."
            )
        }
    }
}
