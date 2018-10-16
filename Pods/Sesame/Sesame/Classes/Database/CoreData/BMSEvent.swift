//
//  BMSEvent+CoreDataClass.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

@objc(BMSEvent)
class BMSEvent: NSManagedObject {
    static let AppOpenName = "appOpen"

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Int64(Date().timeIntervalSince1970 * 1000), forKey: #keyPath(BMSEvent.utc))
        setPrimitiveValue(Int64(NSTimeZone.default.secondsFromGMT() * 1000), forKey: #keyPath(BMSEvent.timezoneOffset))
    }
}

extension BMSEvent {

    @discardableResult
    class func insert(context: NSManagedObjectContext, userId: String, actionName: String, reinforcement: BMSReinforcement? = nil, sessionId: NSNumber? = nil, metadata: [String: Any] = [:]) -> BMSEvent? {
        var value: BMSEvent?
        context.performAndWait {
            guard let report = BMSReport.fetch(context: context, userId: userId, actionName: actionName) ??
                BMSReport.insert(context: context, userId: userId, actionName: actionName),
                let event = BMSEvent.create(in: context) else {
                    return
            }
            event.report = report
            event.reinforcement = reinforcement
            event.sessionId = sessionId
            event.metadataAsDictionary = metadata
            do {
                try context.save()
                BMSLog.info("Logged event #\(report.events.count) with actionName:\(actionName)")
            } catch {
                BMSLog.error(error)
            }
            value = event
        }
        return value
    }

    class func count(context: NSManagedObjectContext, userId: String? = nil) -> Int? {
        var value: Int?
        context.performAndWait {
            let request = BMSEvent.request()
            if let userId = userId {
                request.predicate = NSPredicate(format: "\(#keyPath(BMSEvent.report.user.id)) == '\(userId)'")
            }
            do {
                value = try context.count(for: request)
            } catch let error as NSError {
                BMSLog.error("Could not fetch. \(error)")
            }
        }
        return value
    }

}
