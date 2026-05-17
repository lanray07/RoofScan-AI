import UIKit

enum ImageUtilities {
    static func normalizedJPEGData(from data: Data, maxDimension: CGFloat = 1800, compressionQuality: CGFloat = 0.82) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return image.resized(maxDimension: maxDimension).jpegData(compressionQuality: compressionQuality)
    }
}

extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let largestSide = max(size.width, size.height)
        guard largestSide > maxDimension else { return self }

        let scale = maxDimension / largestSide
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
