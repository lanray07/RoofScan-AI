import Foundation
import Observation

@MainActor
@Observable
final class PhotoCaptureViewModel {
    var selectedLabel: PhotoLabel = .frontElevation
    var notes = ""
    var selectedImageData: Data?
    var errorMessage: String?

    var canAddPhoto: Bool {
        selectedImageData != nil
    }

    func makePhoto(for inspectionID: UUID) -> RoofPhoto? {
        guard let data = selectedImageData else {
            errorMessage = "Take or upload a roof photo first."
            return nil
        }

        let photo = RoofPhoto(
            inspectionId: inspectionID,
            imageData: data,
            label: selectedLabel,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        selectedImageData = nil
        notes = ""
        selectedLabel = .frontElevation
        return photo
    }
}
