import Foundation
import Observation

@MainActor
@Observable
final class InspectionFormViewModel {
    var propertyAddress = ""
    var clientName = ""
    var roofType: RoofType = .pitched
    var inspectionPurpose: InspectionPurpose = .routineInspection
    var notes = ""
    var errorMessage: String?

    var canSave: Bool {
        !propertyAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeInspection() -> RoofInspection? {
        let address = propertyAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let client = clientName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !address.isEmpty, !client.isEmpty else {
            errorMessage = "Add a client name and property address before saving."
            return nil
        }

        return RoofInspection(
            propertyAddress: address,
            clientName: client,
            roofType: roofType,
            inspectionPurpose: inspectionPurpose,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
