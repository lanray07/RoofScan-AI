import Foundation

enum MockData {
    static let sampleInspection = RoofInspection(
        propertyAddress: "12 Slate Yard, Bristol BS1 4RF",
        clientName: "Harper Property Group",
        roofType: .slate,
        inspectionPurpose: .stormDamage,
        notes: "Client reported water staining after heavy wind and rain."
    )

    static func sampleIssues(for inspectionID: UUID, photoID: UUID? = nil) -> [RoofIssue] {
        [
            RoofIssue(
                inspectionId: inspectionID,
                photoId: photoID,
                title: "Possible lifted flashing",
                description: "The image appears to show a visible edge around the flashing that may need closer inspection.",
                category: .flashingConcern,
                severity: .high,
                confidence: 0.78,
                suggestedAction: "Recommend professional inspection and repair soon if movement is confirmed.",
                resolution: .repairSoon
            ),
            RoofIssue(
                inspectionId: inspectionID,
                photoId: photoID,
                title: "Visible moss buildup",
                description: "There is a visible sign of moss or algae buildup that may retain moisture around roof covering materials.",
                category: .mossAlgaeBuildup,
                severity: .medium,
                confidence: 0.72,
                suggestedAction: "Monitor and consider safe cleaning by a qualified roofing professional.",
                resolution: .monitor
            )
        ]
    }
}
