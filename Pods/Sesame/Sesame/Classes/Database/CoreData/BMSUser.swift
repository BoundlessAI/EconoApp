//
//  BMSUser+CoreDataClass.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

@objc(BMSUser)
class BMSUser: NSManagedObject {

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID().uuidString, forKey: #keyPath(BMSUser.id))
    }

}

extension BMSUser {

    class func fetch(context: NSManagedObjectContext, id: String) -> BMSUser? {
        var value: BMSUser?
        context.performAndWait {
            let request = BMSUser.request()
            request.predicate = NSPredicate(format: "\(#keyPath(BMSUser.id)) == '\(id)'")
            request.fetchLimit = 1
            do {
                value = try context.fetch(request).first
            } catch let error as NSError {
                BMSLog.error("Could not fetch. \(error)")
            }
        }
        return value
    }

    @discardableResult
    class func delete(context: NSManagedObjectContext) -> Int? {
        var value: Int?
        context.performAndWait {
            let request = BMSUser.request()
            do {
                value = try context.fetch(request).map({context.delete($0)}).count
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                BMSLog.error(error)
            }
        }
        return value
    }

    class func insert(context: NSManagedObjectContext, id: String) -> BMSUser? {
        var value: BMSUser?
        context.performAndWait {
            let request = BMSUser.request()
            request.predicate = NSPredicate(format: "\(#keyPath(BMSUser.id)) == '\(id)'")
            if let user = BMSUser.create(in: context) {
                user.id = id
                do {
                    try context.save()
                } catch let error as NSError {
                    BMSLog.error("Could not fetch. \(error)")
                }
                value = user
            }
        }
        return value
    }
}
