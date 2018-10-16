//
//  BMSEventMetadataOption.swift
//  Sesame
//
//  Created by Akash Desai on 9/13/18.
//

import UIKit

public typealias BMSEventMetadataOptions = [BMSEventMetadataOption]

public extension Array where Element == BMSEventMetadataOption {

    static func standard() -> BMSEventMetadataOptions {
//        return [.deviceModel, .carrier, .country, .language]
        return []
    }

    mutating func enable(_ option: BMSEventMetadataOption) {
        if !contains(option) {
            append(option)
        }
    }

    mutating func disable(_ option: BMSEventMetadataOption) {
        if let idx = index(of: option) {
            remove(at: idx)
        }
    }

    func annotate(_ dict: inout [String: Any]) {
        for option in self {
            dict[option.key] = option.getValue()
        }
    }

}

@objc
public enum BMSEventMetadataOption: Int {
    case carrier, deviceModel, language, country

    var key: String {
        switch self {
        case .deviceModel: return "deviceModel"
        case .carrier: return "carrier"
        case .country: return "country"
        case .language: return "language"
        }
    }

    func getValue() -> Any? {
        switch self {
        case .deviceModel:
            return UIDevice.modelName

        case .carrier:
            return UIDevice.carrier ?? "unknown"

        case .country:
            return (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "unknown"

        case .language:
            return NSLocale.preferredLanguages.first ?? "unknown"
        }
    }
}
