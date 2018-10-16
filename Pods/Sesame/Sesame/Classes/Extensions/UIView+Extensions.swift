//
//  UIView+Extensions.swift
//  Sesame
//
//  Created by Akash Desai on 12/1/17.
//

import UIKit

extension UIView {
    func generateMask(color: UIColor = .clear) -> UIView {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            color.setFill()
            UIBezierPath(rect: CGRect(origin: .zero, size: self.bounds.size)).fill(with: .sourceAtop, alpha: 1.0)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return UIImageView(image: image)
    }
}
