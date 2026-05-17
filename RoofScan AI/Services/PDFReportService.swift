import Foundation
import UIKit

struct BusinessProfile {
    var businessName: String
    var contactName: String
    var phone: String
    var email: String
    var logoData: Data?
}

struct PDFReportPayload {
    let inspection: RoofInspection
    let photos: [RoofPhoto]
    let issues: [RoofIssue]
    let summary: String
    let priorityList: [String]
    let businessProfile: BusinessProfile
    let includeBranding: Bool
    let includeBusinessBranding: Bool
}

protocol PDFReportGenerating {
    func generatePDF(payload: PDFReportPayload) async throws -> URL
}

struct PDFReportService: PDFReportGenerating {
    func generatePDF(payload: PDFReportPayload) async throws -> URL {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        let reportsDirectory = try reportsDirectory()
        let fileName = makeFileName(for: payload.inspection)
        let fileURL = reportsDirectory.appendingPathComponent(fileName)

        try renderer.writePDF(to: fileURL) { context in
            context.beginPage()
            var y: CGFloat = 42
            let margin: CGFloat = 42
            let contentWidth = pageBounds.width - (margin * 2)

            func ensureSpace(_ height: CGFloat) {
                if y + height > pageBounds.height - margin {
                    context.beginPage()
                    y = margin
                }
            }

            func drawText(_ text: String, font: UIFont, color: UIColor = .label, spacing: CGFloat = 8) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                paragraph.lineSpacing = 2

                let attributed = NSAttributedString(
                    string: text,
                    attributes: [
                        .font: font,
                        .foregroundColor: color,
                        .paragraphStyle: paragraph
                    ]
                )
                let rect = attributed.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                ).integral

                ensureSpace(rect.height + spacing)
                attributed.draw(
                    with: CGRect(x: margin, y: y, width: contentWidth, height: rect.height),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )
                y += rect.height + spacing
            }

            func drawRule() {
                ensureSpace(14)
                UIColor.systemGray4.setStroke()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageBounds.width - margin, y: y))
                path.lineWidth = 1
                path.stroke()
                y += 14
            }

            drawText("RoofScan AI Roofing Inspection Report", font: .boldSystemFont(ofSize: 24), color: .systemBlue, spacing: 12)

            if payload.includeBranding,
               let logoData = payload.businessProfile.logoData,
               let logo = UIImage(data: logoData) {
                let logoSize = CGSize(width: 74, height: 74)
                logo.draw(in: CGRect(x: pageBounds.width - margin - logoSize.width, y: 42, width: logoSize.width, height: logoSize.height))
            }

            if payload.includeBranding, !payload.businessProfile.businessName.isEmpty {
                drawText(payload.businessProfile.businessName, font: .boldSystemFont(ofSize: 16), spacing: 2)
                let contact = [payload.businessProfile.contactName, payload.businessProfile.phone, payload.businessProfile.email]
                    .filter { !$0.isEmpty }
                    .joined(separator: " | ")
                if !contact.isEmpty {
                    drawText(contact, font: .systemFont(ofSize: 10), color: .secondaryLabel, spacing: 8)
                }
            }

            drawRule()
            drawText("Client: \(payload.inspection.clientName)", font: .boldSystemFont(ofSize: 13), spacing: 3)
            drawText("Property: \(payload.inspection.propertyAddress)", font: .systemFont(ofSize: 12), spacing: 3)
            drawText("Inspection purpose: \(payload.inspection.inspectionPurpose.displayName)", font: .systemFont(ofSize: 12), spacing: 3)
            drawText("Roof type: \(payload.inspection.roofType.displayName)", font: .systemFont(ofSize: 12), spacing: 10)

            drawText("Summary", font: .boldSystemFont(ofSize: 18), spacing: 6)
            drawText(payload.summary, font: .systemFont(ofSize: 11), spacing: 12)

            drawText("Severity Breakdown", font: .boldSystemFont(ofSize: 18), spacing: 6)
            let approvedIssues = payload.issues.filter(\.userApproved)
            for severity in IssueSeverity.allCases.reversed() {
                let count = approvedIssues.filter { $0.severity == severity }.count
                drawText("\(severity.displayName): \(count)", font: .systemFont(ofSize: 11), spacing: 2)
            }
            y += 6

            drawText("Repair Priority List", font: .boldSystemFont(ofSize: 18), spacing: 6)
            if payload.priorityList.isEmpty {
                drawText("No user-approved repair priorities have been added.", font: .systemFont(ofSize: 11), spacing: 10)
            } else {
                for (index, item) in payload.priorityList.enumerated() {
                    drawText("\(index + 1). \(item)", font: .systemFont(ofSize: 11), spacing: 4)
                }
            }

            drawText("Findings", font: .boldSystemFont(ofSize: 18), spacing: 6)
            if approvedIssues.isEmpty {
                drawText("No user-approved findings have been added.", font: .systemFont(ofSize: 11), spacing: 8)
            } else {
                for issue in approvedIssues.sorted(by: { $0.severity > $1.severity }) {
                    let issueText = """
                    \(issue.severity.displayName) - \(issue.title)
                    Category: \(issue.category.displayName)
                    Confidence: \(issue.confidence.confidenceText)
                    Description: \(issue.issueDescription)
                    Suggested next action: \(issue.suggestedAction)
                    User action: \(issue.resolution.displayName)
                    """
                    drawText(issueText, font: .systemFont(ofSize: 11), spacing: 10)
                }
            }

            drawText("Photo Evidence", font: .boldSystemFont(ofSize: 18), spacing: 6)
            if payload.photos.isEmpty {
                drawText("No roof photos were attached to this report.", font: .systemFont(ofSize: 11), spacing: 8)
            } else {
                for photo in payload.photos {
                    ensureSpace(170)
                    drawText(photo.label.displayName, font: .boldSystemFont(ofSize: 12), spacing: 3)
                    if !photo.notes.isEmpty {
                        drawText(photo.notes, font: .systemFont(ofSize: 10), color: .secondaryLabel, spacing: 4)
                    }
                    if let data = photo.imageData, let image = UIImage(data: data) {
                        let maxImageSize = CGSize(width: contentWidth, height: 130)
                        let scale = min(maxImageSize.width / image.size.width, maxImageSize.height / image.size.height, 1)
                        let imageSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                        ensureSpace(imageSize.height + 10)
                        image.draw(in: CGRect(x: margin, y: y, width: imageSize.width, height: imageSize.height))
                        y += imageSize.height + 10
                    }
                }
            }

            drawText("Inspector Notes", font: .boldSystemFont(ofSize: 18), spacing: 6)
            drawText(payload.inspection.notes.isEmpty ? "No additional inspector notes supplied." : payload.inspection.notes, font: .systemFont(ofSize: 11), spacing: 12)

            drawText("AI Disclaimer", font: .boldSystemFont(ofSize: 18), spacing: 6)
            drawText(AppConstants.reportDisclaimer, font: .systemFont(ofSize: 9), color: .secondaryLabel, spacing: 12)

            if !payload.includeBranding {
                drawText("Generated with RoofScan AI", font: .boldSystemFont(ofSize: 10), color: .systemBlue, spacing: 8)
            }

            drawText("Signature: ________________________________", font: .systemFont(ofSize: 12), spacing: 4)
            drawText("Date: ____________________", font: .systemFont(ofSize: 12), spacing: 4)

            if payload.includeBusinessBranding {
                drawText("Business template: Insurance documentation and contractor action workflow placeholders included.", font: .italicSystemFont(ofSize: 9), color: .secondaryLabel, spacing: 4)
            }
        }

        return fileURL
    }

    private func reportsDirectory() throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("RoofScanReports", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private func makeFileName(for inspection: RoofInspection) -> String {
        let rawName = "\(inspection.clientName)-\(inspection.propertyAddress)-\(AppFormatters.fileSafeDate.string(from: .now))"
        let safeName = rawName.replacingOccurrences(of: "[^A-Za-z0-9-]+", with: "-", options: .regularExpression)
        return "\(safeName).pdf"
    }
}
