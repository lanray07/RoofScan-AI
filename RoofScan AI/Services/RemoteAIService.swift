import Foundation

struct RemoteAIService: AIService {
    private let endpoint: URL
    private let session: URLSession

    init(endpoint: URL = AppConstants.backendEndpoint, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    func scanRoofPhoto(_ imageData: Data, context: AIPhotoScanContext) async throws -> AIPhotoScanResult {
        guard endpoint.absoluteString != "https://YOUR_BACKEND_URL.com/roof-scan" else {
            throw AIServiceError.backendNotConfigured
        }

        let requestBody = RoofScanRequest(
            roofType: context.roofType.displayName,
            inspectionPurpose: context.inspectionPurpose.displayName,
            photoLabel: context.photoLabel.displayName,
            userNotes: context.userNotes,
            imageBase64: imageData.base64EncodedString()
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw AIServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(RoofScanResponse.self, from: data)
        let issues = decoded.issues.map {
            AIDetectedIssue(
                title: $0.title,
                description: $0.description,
                category: IssueCategory(remoteValue: $0.category),
                severity: IssueSeverity(remoteValue: $0.severity),
                confidence: min(max($0.confidence, 0), 1),
                suggestedAction: $0.suggestedAction
            )
        }

        return AIPhotoScanResult(issues: issues, summary: decoded.summary)
    }

    func generateInspectionSummary(inspection: RoofInspection, issues: [RoofIssue]) async throws -> String {
        let approved = issues.filter(\.userApproved)
        let urgent = approved.filter { $0.severity == .urgent }.count
        return "Remote scan findings for \(inspection.propertyAddress) include \(approved.count) approved item(s), including \(urgent) urgent item(s). Review all findings before issuing the report."
    }

    func generateRepairPriorityList(issues: [RoofIssue]) async throws -> [String] {
        issues
            .filter(\.userApproved)
            .sorted { $0.severity > $1.severity }
            .map { "\($0.severity.displayName): \($0.title) - \($0.suggestedAction)" }
    }

    func generateReportText(inspection: RoofInspection, issues: [RoofIssue], summary: String) async throws -> String {
        let issueLines = issues
            .filter(\.userApproved)
            .map { "- \($0.title): \($0.issueDescription)" }
            .joined(separator: "\n")

        return """
        \(summary)

        Approved findings:
        \(issueLines)

        \(AppConstants.reportDisclaimer)
        """
    }
}

private struct RoofScanRequest: Encodable {
    let roofType: String
    let inspectionPurpose: String
    let photoLabel: String
    let userNotes: String
    let imageBase64: String
}

private struct RoofScanResponse: Decodable {
    let issues: [RoofScanIssueResponse]
    let summary: String
}

private struct RoofScanIssueResponse: Decodable {
    let title: String
    let description: String
    let category: String
    let severity: String
    let confidence: Double
    let suggestedAction: String
}
