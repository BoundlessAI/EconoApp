//
//  Bundle+Extensions.swift
//  Sesame
//
//  Created by Akash Desai on 11/27/17.
//

import Foundation

internal extension Bundle {
    class var sesame: Bundle? {
        if let bundleURL = Bundle(for: Sesame.classForCoder()).url(forResource: "Sesame", withExtension: "bundle") {
            return Bundle(url: bundleURL)
        } else {
            BMSLog.error("The Sesame framework bundle cannot be found")
            return nil
        }
    }

    var shortVersionString: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
