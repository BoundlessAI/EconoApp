//
//  CG+Extensions.swift
//  Sesame
//
//  Created by Akash Desai on 12/1/17.
//

import CoreImage

internal extension CGImage {
    func blurImage(radius: Int) -> CGImage {
        guard radius != 0 else {
            return self
        }
        let imageToBlur = CIImage(cgImage: self)
        let blurfilter = CIFilter(name: "CIGaussianBlur")!
        blurfilter.setValue(radius, forKey: kCIInputRadiusKey)
        blurfilter.setValue(imageToBlur, forKey: kCIInputImageKey)
        guard let resultImage = blurfilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            return self
        }

        let context = CIContext(options: nil)
        return context.createCGImage(resultImage, from: resultImage.extent)!
    }
}

internal extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return self / 180 * .pi
    }

    init(degrees: CGFloat) {
        self = degrees.degreesToRadians()
    }
}

internal extension CGRect {
    func pointWithMargins(x marginX: CGFloat, y marginY: CGFloat) -> CGPoint {
        return CGPoint(x: (-1 <= marginX && marginX <= 1) ? marginX * width : marginX,
                       y: (-1 <= marginY && marginY <= 1) ? marginY * height : marginY)
    }
}
