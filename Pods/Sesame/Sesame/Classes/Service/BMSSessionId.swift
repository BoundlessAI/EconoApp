//
//  BMSSessionId.swift
//  Sesame
//
//  Created by Akash Desai on 9/19/18.
//

import Foundation

typealias BMSSessionId = Int64

extension Optional where Wrapped == BMSSessionId {
    static var new: BMSSessionId { return Int64( Date().timeIntervalSince1970 * 1000 ) }
}

extension BMSSessionId {
    static let AppOpenName = "BMSSessionSessionAppOpen"
    static let AppCloseName = "BMSSessionAppClose"
    static let StartName = "BMSSessionStart"
    static let EndName = "BMSSessionEnd"
    static let InterruptionStartName = "BMSSessionInterruptionStart"
    static let InterruptionEndName = "BMSSessionInterruptionEnd"
    static let TimeElapsedName = "BMSSessionTimeElapsed"

    func timeElapsed() -> Int64 {
        return BMSSessionId?.new - self
    }
}
