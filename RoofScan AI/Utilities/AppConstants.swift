import Foundation
import SwiftUI

enum AppConstants {
    static let backendEndpoint = URL(string: "https://YOUR_BACKEND_URL.com/roof-scan")!
    static let privacyPolicyURL = URL(string: "https://github.com/lanray07/RoofScan-AI/blob/main/PRIVACY.md")!
    static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let supportURL = URL(string: "https://github.com/lanray07/RoofScan-AI/issues")!

    static let internalAIPrompt = """
    You are RoofScan AI, an AI assistant for visual roofing inspection reports. Review the user's roof photo description, roof type, inspection purpose, and notes. Identify visible, non-diagnostic roofing issues only. Do not claim certainty. Do not provide structural certification, legal advice, insurance approval advice, or safety certification. Use cautious language such as 'possible', 'visible sign of', 'appears to show', and 'recommend professional inspection' where appropriate. Return structured findings with severity, category, explanation, confidence level, and suggested next action.
    """

    static let disclaimerBullets = [
        "AI findings are visual suggestions only.",
        "Not a certified roof inspection.",
        "Not structural engineering advice.",
        "Not insurance claim approval advice.",
        "Not legal advice.",
        "AI findings must be reviewed by a qualified professional.",
        "Users should not climb roofs or take unsafe photos.",
        "Urgent safety issues should be checked by professionals immediately."
    ]

    static let reportDisclaimer = """
    RoofScan AI findings are visual suggestions only and are not a replacement for a certified roof inspection, structural inspection, electrical inspection, insurance claim approval advice, or legal advice. All findings must be reviewed and verified by a qualified professional before they are used for repair, safety, insurance, or legal decisions. Users should not climb roofs or take unsafe photos. Urgent safety issues should be checked by professionals immediately.
    """
}

enum AppTheme {
    static let blue = Color(red: 0.12, green: 0.47, blue: 0.84)
    static let orange = Color(red: 0.93, green: 0.42, blue: 0.12)
    static let charcoal = Color(red: 0.12, green: 0.14, blue: 0.16)
    static let fieldBackground = Color(.secondarySystemGroupedBackground)
    static let cardBackground = Color(.systemBackground)
    static let pageBackground = Color(.systemGroupedBackground)
}
