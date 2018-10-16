//
//  UIWindow+Extensions.swift
//  Sesame
//
//  Created by Akash Desai on 9/20/18.
//

import UIKit

extension UIWindow {
    class var topWindow: UIWindow? {
        guard let sharedApplication = UIApplication.sharedIfAvailable else { return nil }
        if let window = sharedApplication.keyWindow {
            return window
        }
        for window in sharedApplication.windows.reversed() {
            if window.windowLevel == .normal && !window.isHidden && window.frame != .zero {
                return window
            }
        }
        return nil
    }
}
