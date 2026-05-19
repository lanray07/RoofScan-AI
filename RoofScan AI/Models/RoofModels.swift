import Foundation
import SwiftData

enum UserType: String, CaseIterable, Identifiable, Codable {
    case roofer
    case contractor
    case propertyManager
    case landlord
    case estateAgent
    case insuranceClaimAssistant
    case homeInspector

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .roofer: "Roofer"
        case .contractor: "Contractor"
        case .propertyManager: "Property manager"
        case .landlord: "Landlord"
        case .estateAgent: "Estate agent"
        case .insuranceClaimAssistant: "Insurance claim assistant"
        case .homeInspector: "Home inspector"
        }
    }
}

enum RoofType: String, CaseIterable, Identifiable, Codable {
    case pitched
    case flat
    case tile
    case slate
    case asphaltShingle
    case metal
    case commercial

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pitched: "Pitched roof"
        case .flat: "Flat roof"
        case .tile: "Tile roof"
        case .slate: "Slate roof"
        case .asphaltShingle: "Asphalt shingle roof"
        case .metal: "Metal roof"
        case .commercial: "Commercial roof"
        }
    }
}

enum InspectionPurpose: String, CaseIterable, Identifiable, Codable {
    case routineInspection
    case stormDamage
    case leakInvestigation
    case preSaleInspection
    case insuranceDocumentation
    case maintenanceCheck

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .routineInspection: "Routine inspection"
        case .stormDamage: "Storm damage"
        case .leakInvestigation: "Leak investigation"
        case .preSaleInspection: "Pre-sale inspection"
        case .insuranceDocumentation: "Insurance documentation"
        case .maintenanceCheck: "Maintenance check"
        }
    }
}

enum InspectionStatus: String, CaseIterable, Identifiable, Codable {
    case draft
    case photosAdded
    case scanned
    case reviewed
    case reportGenerated

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .draft: "Draft"
        case .photosAdded: "Photos added"
        case .scanned: "AI scanned"
        case .reviewed: "Reviewed"
        case .reportGenerated: "Report generated"
        }
    }
}

enum PhotoLabel: String, CaseIterable, Identifiable, Codable {
    case frontElevation
    case rearElevation
    case leftSide
    case rightSide
    case gutter
    case chimney
    case flashing
    case ridge
    case valley
    case flatRoofSurface
    case interiorLeakEvidence

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .frontElevation: "Front elevation"
        case .rearElevation: "Rear elevation"
        case .leftSide: "Left side"
        case .rightSide: "Right side"
        case .gutter: "Gutter"
        case .chimney: "Chimney"
        case .flashing: "Flashing"
        case .ridge: "Ridge"
        case .valley: "Valley"
        case .flatRoofSurface: "Flat roof surface"
        case .interiorLeakEvidence: "Interior leak evidence"
        }
    }
}

enum IssueSeverity: String, CaseIterable, Identifiable, Codable, Comparable {
    case low
    case medium
    case high
    case urgent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .urgent: "Urgent"
        }
    }

    var priorityRank: Int {
        switch self {
        case .low: 1
        case .medium: 2
        case .high: 3
        case .urgent: 4
        }
    }

    static func < (lhs: IssueSeverity, rhs: IssueSeverity) -> Bool {
        lhs.priorityRank < rhs.priorityRank
    }
}

enum IssueCategory: String, CaseIterable, Identifiable, Codable {
    case missingBrokenTiles
    case crackedSlate
    case damagedShingles
    case mossAlgaeBuildup
    case gutterBlockage
    case flashingConcern
    case chimneyConcern
    case visibleLeakIndicator
    case flatRoofPooling
    case membraneDamage
    case saggingStructuralVisualConcern
    case stormHailWindDamage
    case generalWear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .missingBrokenTiles: "Missing/broken tiles"
        case .crackedSlate: "Cracked slate"
        case .damagedShingles: "Damaged shingles"
        case .mossAlgaeBuildup: "Moss/algae buildup"
        case .gutterBlockage: "Gutter blockage"
        case .flashingConcern: "Flashing concern"
        case .chimneyConcern: "Chimney concern"
        case .visibleLeakIndicator: "Visible leak indicator"
        case .flatRoofPooling: "Flat roof pooling"
        case .membraneDamage: "Membrane damage"
        case .saggingStructuralVisualConcern: "Sagging/structural visual concern"
        case .stormHailWindDamage: "Storm/hail/wind damage"
        case .generalWear: "General wear"
        }
    }
}

enum IssueResolution: String, CaseIterable, Identifiable, Codable {
    case monitor
    case repairSoon
    case urgentRepair
    case professionalSurveyNeeded

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .monitor: "Monitor"
        case .repairSoon: "Repair soon"
        case .urgentRepair: "Urgent repair"
        case .professionalSurveyNeeded: "Professional survey needed"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free
    case proMonthly
    case proYearly
    case businessMonthly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .proMonthly: "Pro Monthly"
        case .proYearly: "Pro Yearly"
        case .businessMonthly: "Business Monthly"
        }
    }

    var priceText: String {
        switch self {
        case .free: "GBP 0"
        case .proMonthly: "GBP 24.99 / month"
        case .proYearly: "GBP 199.99 / year"
        case .businessMonthly: "GBP 79.99 / month"
        }
    }

    var subscriptionLengthText: String {
        switch self {
        case .free: "No renewal"
        case .proMonthly, .businessMonthly: "1 month"
        case .proYearly: "1 year"
        }
    }

    var productID: String? {
        switch self {
        case .free: nil
        case .proMonthly: "com.roofscanai.pro.monthly"
        case .proYearly: "com.roofscanai.pro.yearly"
        case .businessMonthly: "com.roofscanai.business.monthly"
        }
    }

    var includedScanLimit: Int? {
        switch self {
        case .free: 10
        case .proMonthly, .proYearly: 250
        case .businessMonthly: nil
        }
    }
}

@Model
final class RoofInspection {
    @Attribute(.unique) var id: UUID
    var propertyAddress: String
    var clientName: String
    var roofTypeRawValue: String
    var inspectionPurposeRawValue: String
    var notes: String
    var statusRawValue: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        propertyAddress: String,
        clientName: String,
        roofType: RoofType,
        inspectionPurpose: InspectionPurpose,
        notes: String = "",
        status: InspectionStatus = .draft,
        createdAt: Date = .now
    ) {
        self.id = id
        self.propertyAddress = propertyAddress
        self.clientName = clientName
        self.roofTypeRawValue = roofType.rawValue
        self.inspectionPurposeRawValue = inspectionPurpose.rawValue
        self.notes = notes
        self.statusRawValue = status.rawValue
        self.createdAt = createdAt
    }

    var roofType: RoofType {
        get { RoofType(rawValue: roofTypeRawValue) ?? .pitched }
        set { roofTypeRawValue = newValue.rawValue }
    }

    var inspectionPurpose: InspectionPurpose {
        get { InspectionPurpose(rawValue: inspectionPurposeRawValue) ?? .routineInspection }
        set { inspectionPurposeRawValue = newValue.rawValue }
    }

    var status: InspectionStatus {
        get { InspectionStatus(rawValue: statusRawValue) ?? .draft }
        set { statusRawValue = newValue.rawValue }
    }
}

@Model
final class RoofPhoto {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var localImageURL: URL?
    var labelRawValue: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        imageData: Data? = nil,
        localImageURL: URL? = nil,
        label: PhotoLabel,
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.imageData = imageData
        self.localImageURL = localImageURL
        self.labelRawValue = label.rawValue
        self.notes = notes
        self.createdAt = createdAt
    }

    var label: PhotoLabel {
        get { PhotoLabel(rawValue: labelRawValue) ?? .frontElevation }
        set { labelRawValue = newValue.rawValue }
    }
}

@Model
final class RoofIssue {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    var photoId: UUID?
    var title: String
    var issueDescription: String
    var categoryRawValue: String
    var severityRawValue: String
    var confidence: Double
    var suggestedAction: String
    var userApproved: Bool
    var resolutionRawValue: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        photoId: UUID? = nil,
        title: String,
        description: String,
        category: IssueCategory,
        severity: IssueSeverity,
        confidence: Double,
        suggestedAction: String,
        userApproved: Bool = true,
        resolution: IssueResolution = .monitor,
        createdAt: Date = .now
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.photoId = photoId
        self.title = title
        self.issueDescription = description
        self.categoryRawValue = category.rawValue
        self.severityRawValue = severity.rawValue
        self.confidence = confidence
        self.suggestedAction = suggestedAction
        self.userApproved = userApproved
        self.resolutionRawValue = resolution.rawValue
        self.createdAt = createdAt
    }

    var category: IssueCategory {
        get { IssueCategory(rawValue: categoryRawValue) ?? .generalWear }
        set { categoryRawValue = newValue.rawValue }
    }

    var severity: IssueSeverity {
        get { IssueSeverity(rawValue: severityRawValue) ?? .low }
        set { severityRawValue = newValue.rawValue }
    }

    var resolution: IssueResolution {
        get { IssueResolution(rawValue: resolutionRawValue) ?? .monitor }
        set { resolutionRawValue = newValue.rawValue }
    }
}

@Model
final class RoofReport {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    var title: String
    var summary: String
    var pdfLocalURL: URL?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        title: String,
        summary: String,
        pdfLocalURL: URL? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.title = title
        self.summary = summary
        self.pdfLocalURL = pdfLocalURL
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var planRawValue: String
    var isActive: Bool
    var renewsAt: Date?

    init(
        id: UUID = UUID(),
        plan: SubscriptionPlan = .free,
        isActive: Bool = false,
        renewsAt: Date? = nil
    ) {
        self.id = id
        self.planRawValue = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }

    var plan: SubscriptionPlan {
        get { SubscriptionPlan(rawValue: planRawValue) ?? .free }
        set { planRawValue = newValue.rawValue }
    }
}
