import SwiftUI
import UIKit

struct BundlePNGImage: View {
    let name: String
    var contentMode: ContentMode = .fit

    private static let cache = NSCache<NSString, UIImage>()

    var body: some View {
        if let image = Self.loadImage(named: name) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundStyle(.white.opacity(0.65))
                )
        }
    }

    private static func loadImage(named name: String) -> UIImage? {
        if let cachedImage = cache.object(forKey: name as NSString) {
            return cachedImage
        }

        if let assetImage = UIImage(named: name) {
            cache.setObject(assetImage, forKey: name as NSString)
            return assetImage
        }

        if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Images") {
            let image = UIImage(contentsOfFile: url.path)
            if let image {
                cache.setObject(image, forKey: name as NSString)
            }
            return image
        }

        if let url = Bundle.main.url(forResource: name, withExtension: "png") {
            let image = UIImage(contentsOfFile: url.path)
            if let image {
                cache.setObject(image, forKey: name as NSString)
            }
            return image
        }

        return nil
    }
}