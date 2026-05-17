import SwiftUI

private struct AIServiceKey: EnvironmentKey {
    static let defaultValue: any AIService = MockAIService()
}

private struct PDFReportServiceKey: EnvironmentKey {
    static let defaultValue: any PDFReportGenerating = PDFReportService()
}

extension EnvironmentValues {
    var aiService: any AIService {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }

    var pdfReportService: any PDFReportGenerating {
        get { self[PDFReportServiceKey.self] }
        set { self[PDFReportServiceKey.self] = newValue }
    }
}
