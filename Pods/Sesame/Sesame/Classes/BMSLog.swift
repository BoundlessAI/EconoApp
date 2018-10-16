//
//  BMSLog.swift
//  Sesame
//
//  Created by Akash Desai on 7/23/18.
//

import Foundation

@objc open class BMSLog: NSObject {

    @objc public enum Level: Int, CustomStringConvertible, Comparable {
        case none, error, warning, info, verbose

        public var description: String {
            switch self {
            case .none: return "none"
            case .error: return "error"
            case .warning: return "warning"
            case .info: return "info"
            case .verbose: return "verbose"
            }
        }

        public static func < (lhs: BMSLog.Level, rhs: BMSLog.Level) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    @objc public static var level = Level.verbose

    @objc open class func verbose(_ message: Any, filePath: String = #file, function: String = #function, line: Int = #line) {
        BMSLog.print(.verbose, message, filePath: filePath, function: function, line: line)
    }

    @objc open class func info(_ message: Any, filePath: String = #file, function: String =  #function, line: Int = #line) {
        BMSLog.print(.info, message, filePath: filePath, function: function, line: line)
    }

    @objc open class func info(confirmed message: Any, filePath: String = #file, function: String =  #function, line: Int = #line) {
        BMSLog.print(.info, "✅ \(message)", filePath: filePath, function: function, line: line)
    }

    @objc open class func warning(_ message: Any, filePath: String = #file, function: String =  #function, line: Int = #line) {
        BMSLog.print(.warning, "⚠️ \(message)", filePath: filePath, function: function, line: line)
    }

    @objc open class func error(_ message: Any, filePath: String = #file, function: String =  #function, line: Int = #line) {
        BMSLog.print(.error, "❌ \(message)", filePath: filePath, function: function, line: line)
    }

    @objc open class func print(_ level: Level, _ message: Any, filePath: String = #file, function: String =  #function, line: Int = #line) {
        guard level <= BMSLog.level else { return }
        var functionSignature = function
        if let parameterNames = functionSignature.range(of: "\\((.*?)\\)", options: .regularExpression) {
            functionSignature.replaceSubrange(parameterNames, with: "()")
        }
        let fileName = (filePath as NSString).lastPathComponent
        Swift.print("[\(fileName):\(line):\(functionSignature) \(level)] - \(message)")
    }

}
