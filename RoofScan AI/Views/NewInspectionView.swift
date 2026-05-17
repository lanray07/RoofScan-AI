import SwiftData
import SwiftUI

struct NewInspectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @State private var viewModel = InspectionFormViewModel()

    var body: some View {
        Form {
            Section("Property details") {
                TextField("Property address", text: $viewModel.propertyAddress, axis: .vertical)
                    .textInputAutocapitalization(.words)
                TextField("Client name", text: $viewModel.clientName)
                    .textInputAutocapitalization(.words)
            }

            Section("Roof") {
                Picker("Roof type", selection: $viewModel.roofType) {
                    ForEach(RoofType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }

                Picker("Inspection purpose", selection: $viewModel.inspectionPurpose) {
                    ForEach(InspectionPurpose.allCases) { purpose in
                        Text(purpose.displayName).tag(purpose)
                    }
                }
            }

            Section("Notes") {
                TextField("Inspector notes", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(4...8)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("New Inspection")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create") {
                    saveInspection()
                }
                .disabled(!viewModel.canSave)
            }
        }
    }

    private func saveInspection() {
        guard let inspection = viewModel.makeInspection() else { return }
        modelContext.insert(inspection)

        do {
            try modelContext.save()
            router.navigate(to: .photoCapture(inspection.id))
        } catch {
            viewModel.errorMessage = "Unable to save inspection. \(error.localizedDescription)"
        }
    }
}
