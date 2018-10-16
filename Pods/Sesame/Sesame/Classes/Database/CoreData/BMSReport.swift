//
//  BMSReport+CoreDataClass.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

@objc(BMSReport)
class BMSReport: NSManagedObject { }

extension BMSReport {

    class func fetch(context: NSManagedObjectContext, userId: String) -> [BMSReport]? {
        var values: [BMSReport]?
        context.performAndWait {
            let request = BMSReport.request()
            request.predicate = NSPredicate(format: "\(#keyPath(BMSReport.user.id)) == '\(userId)'")
            do {
                values = try context.fetch(request)
            } catch let error as NSError {
                BMSLog.error("Could not fetch. \(error)")
            }
        }
        return values
    }

    class func fetch(context: NSManagedObjectContext, userId: String, actionName: String) -> BMSReport? {
        var value: BMSReport?
        context.performAndWait {
            let request = BMSReport.request()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(BMSReport.user.id)) == '\(userId)'"),
                NSPredicate(format: "\(#keyPath(BMSReport.actionName)) == '\(actionName)'")
                ])
            request.fetchLimit = 1
            do {
                value = try context.fetch(request).first
            } catch {
                BMSLog.error("Could not fetch. \(error)")
            }
        }
        return value
    }

    class func insert(context: NSManagedObjectContext, userId: String, actionName: String) -> BMSReport? {
        var value: BMSReport?
        context.performAndWait {
            if let user = BMSUser.fetch(context: context, id: userId),
                let report = BMSReport.create(in: context) {
                report.actionName = actionName
                report.user = user
                do {
                    try context.save()
                } catch {
                    BMSLog.error("Could not fetch. \(error)")
                }
                value = report
            }
        }
        return value
    }

}
