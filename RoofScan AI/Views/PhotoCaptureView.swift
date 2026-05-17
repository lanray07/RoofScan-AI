import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct PhotoCaptureView: View {
    let inspectionID: UUID

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @Query private var inspections: [RoofInspection]
    @Query(sort: \RoofPhoto.createdAt, order: .reverse) private var photos: [RoofPhoto]

    @State private var viewModel = PhotoCaptureViewModel()
    @State private var permissionManager = PermissionManager()
    @State private var pickerItem: PhotosPickerItem?
    @State private var showsCamera = false

    private var inspection: RoofInspection? {
        inspections.first { $0.id == inspectionID }
    }

    private var inspectionPhotos: [RoofPhoto] {
        photos.filter { $0.inspectionId == inspectionID }
    }

    var body: some View {
        Group {
            if let inspection {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        inspectionHeader(inspection)
                        captureControls
                        selectedImagePreview
                        addedPhotos
                    }
                    .padding()
                }
                .background(AppTheme.pageBackground)
                .navigationTitle("Roof Photos")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Scan") {
                            router.navigate(to: .aiScan(inspection.id))
                        }
                        .disabled(inspectionPhotos.isEmpty)
                    }
                }
            } else {
                ContentUnavailableView("Inspection not found", systemImage: "exclamationmark.triangle")
            }
        }
        .sheet(isPresented: $showsCamera) {
            CameraPicker { data in
                viewModel.selectedImageData = data
            }
            .ignoresSafeArea()
        }
        .onChange(of: pickerItem) { _, newItem in
            Task { await loadPhoto(from: newItem) }
        }
    }

    private func inspectionHeader(_ inspection: RoofInspection) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(inspection.clientName)
                .font(.headline)
            Text(inspection.propertyAddress)
                .foregroundStyle(.secondary)
            Label(inspection.roofType.displayName, systemImage: "house.lodge")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var captureControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Add roof photo")
                .font(.title3.weight(.bold))

            HStack(spacing: 10) {
                Button {
                    Task { await openCamera() }
                } label: {
                    Label("Take roof photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.blue)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Upload", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Picker("Photo label", selection: $viewModel.selectedLabel) {
                ForEach(PhotoLabel.allCases) { label in
                    Text(label.displayName).tag(label)
                }
            }

            TextField("Photo notes", text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)

            Button {
                addPhoto()
            } label: {
                Label("Add Photo to Inspection", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.orange)
            .disabled(!viewModel.canAddPhoto)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var selectedImagePreview: some View {
        if let data = viewModel.selectedImageData, let image = UIImage(data: data) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Selected photo")
                    .font(.headline)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private var addedPhotos: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Added Photos")
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(inspectionPhotos.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            if inspectionPhotos.isEmpty {
                EmptyStateView(systemImage: "camera", title: "No photos yet", message: "Take or upload roof photos before scanning for visible issues.")
            } else {
                ForEach(inspectionPhotos) { photo in
                    RoofPhotoCard(photo: photo) {
                        modelContext.delete(photo)
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    private func openCamera() async {
        switch permissionManager.cameraStatus {
        case .authorized:
            showsCamera = true
        case .notDetermined:
            if await permissionManager.requestCameraAccess() {
                showsCamera = true
            }
        default:
            viewModel.errorMessage = "Camera access is disabled. Enable camera permission in Settings to take roof photos."
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                viewModel.selectedImageData = ImageUtilities.normalizedJPEGData(from: data) ?? data
            }
        } catch {
            viewModel.errorMessage = "Unable to load selected photo. \(error.localizedDescription)"
        }
    }

    private func addPhoto() {
        guard let photo = viewModel.makePhoto(for: inspectionID) else { return }
        modelContext.insert(photo)
        inspection?.status = .photosAdded

        do {
            try modelContext.save()
        } catch {
            viewModel.errorMessage = "Unable to save photo. \(error.localizedDescription)"
        }
    }
}
