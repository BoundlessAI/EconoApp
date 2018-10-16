//
//  UIColor+Extensions.swift
//  Sesame
//
//  Created by Akash Desai on 12/1/17.
//

import UIKit

public extension UIColor {

    var rgba: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgba: Int = (Int)(r*255)<<24 | (Int)(g*255)<<16 | (Int)(b*255)<<8 | (Int)(a*255)<<0

        return String(format: "#%08x", rgba).uppercased()
    }

    var rgb: String {
        return String(rgba.dropLast(2))
    }

    @objc
    class func from(rgba: String) -> UIColor? {
        var colorString: String = rgba.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()

        if colorString.hasPrefix("#") {
            colorString.removeFirst()
        }

        if colorString.count == 6 {
            colorString += "FF"
        } else if colorString.count != 8 {
            return nil
        }

        var rgbaValue: UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&rgbaValue)

        return UIColor(
            red: CGFloat((rgbaValue & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgbaValue & 0x00FF0000) >> 16) / 255.0,
            blue: CGFloat((rgbaValue & 0x0000FF00) >> 8) / 255.0,
            alpha: CGFloat(rgbaValue & 0x000000FF) / 255.0
        )
    }

    /// This function takes a hex string and alpha value and returns its UIColor
    ///
    /// - parameters:
    ///     - rgb: A hex string with either format `"#ffffff"` or `"ffffff"` or `"#FFFFFF"`.
    ///     - alpha: The alpha value to apply to the color. Default is `1.0`.
    ///
    /// - returns:
    ///     The corresponding UIColor for valid hex strings, `nil` otherwise.
    ///
    @objc
    class func from(rgb: String, alpha: CGFloat = 1.0) -> UIColor? {
        return UIColor.from(rgba: rgb)?.withAlphaComponent(alpha)
    }
}
