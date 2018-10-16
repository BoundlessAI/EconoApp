//
//  BMSUser+CoreDataProperties.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

extension BMSUser {

    @nonobjc public class func request() -> NSFetchRequest<BMSUser> {
        return NSFetchRequest<BMSUser>(entityName: "BMSUser")
    }

    class func create(in context: NSManagedObjectContext) -> BMSUser? {
        guard let entity = NSEntityDescription.entity(forEntityName: "BMSUser", in: context) else {
            return nil
        }
        return BMSUser(entity: entity, insertInto: context)
    }

    @NSManaged var id: String
    @NSManaged var appState: BMSAppState?
    @NSManaged var cartridges: NSSet
    @NSManaged var reports: NSSet

}

// MARK: Generated accessors for cartridges
extension BMSUser {

    @objc(addCartridgesObject:)
    @NSManaged public func addToCartridges(_ value: BMSCartridge)

    @objc(removeCartridgesObject:)
    @NSManaged public func removeFromCartridges(_ value: BMSCartridge)

    @objc(addCartridges:)
    @NSManaged public func addToCartridges(_ values: NSSet)

    @objc(removeCartridges:)
    @NSManaged public func removeFromCartridges(_ values: NSSet)

}

// MARK: Generated accessors for reports
extension BMSUser {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: BMSReport)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: BMSReport)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

}
