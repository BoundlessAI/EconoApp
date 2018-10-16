//
//  UIImage+Extensions.swift
//  Sesame
//
//  Created by Akash Desai on 12/1/17.
//

import UIKit

///
/// For creating an emojisplosion image from text
public extension UIImage {

    /// Creates an image of the given text.
    /// Uses a default font of UIFont.systemFont(ofSize 24)
    ///
    /// - Parameter text: The text create an image for. Supports emojis!
    @objc
    convenience init?(text: String) {
        self.init(text: text, font: .systemFont(ofSize: 24))
    }

    /// Creates an image of the given text
    ///
    /// - Parameters:
    ///   - text: The text create an image for. Supports emojis!
    ///   - font: The font to use when drawing the text
    @objc
    convenience init?(text: String, font: UIFont) {
        let size = text.size(withAttributes: [.font: font])
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        text.draw(at: .zero, withAttributes: [.font: font])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

///
/// For tinting the sheen image
extension UIImage {

    // colorize image with given tint color
    // this is similar to Photoshop's "Color" layer blend mode
    // this is perfect for non-greyscale source images,
    // and images that have both highlights and shadows that should be preserved
    // white will stay white and black will stay black as the lightness of the image is preserved
    func tint(tintColor: UIColor) -> UIImage {

        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)

            // draw original image
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)

            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)

            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }

    // fills the alpha channel of the source image with the given color
    // any color information except to the alpha channel will be ignored
    func fillAlpha(fillColor: UIColor) -> UIImage {

        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)

            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }

    private func modifiedImage(draw: (CGContext, CGRect) -> Void) -> UIImage {

        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        draw(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

}
