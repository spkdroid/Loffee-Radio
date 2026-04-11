import SwiftUI
import UIKit

struct BundlePNGImage: View {
    let name: String
    var contentMode: ContentMode = .fit

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
        if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Images") {
            return UIImage(contentsOfFile: url.path)
        }

        if let url = Bundle.main.url(forResource: name, withExtension: "png") {
            return UIImage(contentsOfFile: url.path)
        }

        return nil
    }
}