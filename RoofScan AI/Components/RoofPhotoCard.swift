import SwiftUI
import UIKit

struct RoofPhotoCard: View {
    let photo: RoofPhoto
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                imageView
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)
                    .background(AppTheme.fieldBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                if let onDelete {
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .font(.callout.weight(.semibold))
                            .frame(width: 34, height: 34)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(8)
                    .accessibilityLabel("Delete photo")
                }
            }

            HStack {
                Label(photo.label.displayName, systemImage: "tag")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(photo.createdAt.roofScanShortDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !photo.notes.isEmpty {
                Text(photo.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var imageView: some View {
        if let data = photo.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.largeTitle)
                Text("Photo unavailable")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
    }
}
