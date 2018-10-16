//
//  BMSCartridge+CoreDataProperties.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

extension BMSCartridge {

    @nonobjc class func request() -> NSFetchRequest<BMSCartridge> {
        return NSFetchRequest<BMSCartridge>(entityName: "BMSCartridge")
    }

    class func create(in context: NSManagedObjectContext) -> BMSCartridge? {
        guard let entity = NSEntityDescription.entity(forEntityName: "BMSCartridge", in: context) else {
            return nil
        }
        return BMSCartridge(entity: entity, insertInto: context)
    }

    @NSManaged var actionId: String
    @NSManaged var cartridgeId: String
    @NSManaged var utc: Int64
    @NSManaged var ttl: Int64
    @NSManaged var reinforcements: NSOrderedSet
    @NSManaged var user: BMSUser

}

// MARK: Generated accessors for reinforcements
extension BMSCartridge {

    @objc(insertObject:inReinforcementsAtIndex:)
    @NSManaged func insertIntoReinforcements(_ value: BMSReinforcement, at idx: Int)

    @objc(removeObjectFromReinforcementsAtIndex:)
    @NSManaged func removeFromReinforcements(at idx: Int)

    @objc(insertReinforcements:atIndexes:)
    @NSManaged func insertIntoReinforcements(_ values: [BMSReinforcement], at indexes: NSIndexSet)

    @objc(removeReinforcementsAtIndexes:)
    @NSManaged func removeFromReinforcements(at indexes: NSIndexSet)

    @objc(replaceObjectInReinforcementsAtIndex:withObject:)
    @NSManaged func replaceReinforcements(at idx: Int, with value: BMSReinforcement)

    @objc(replaceReinforcementsAtIndexes:withReinforcements:)
    @NSManaged func replaceReinforcements(at indexes: NSIndexSet, with values: [BMSReinforcement])

    @objc(addReinforcementsObject:)
    @NSManaged func addToReinforcements(_ value: BMSReinforcement)

    @objc(removeReinforcementsObject:)
    @NSManaged func removeFromReinforcements(_ value: BMSReinforcement)

    @objc(addReinforcements:)
    @NSManaged func addToReinforcements(_ values: NSOrderedSet)

    @objc(removeReinforcements:)
    @NSManaged func removeFromReinforcements(_ values: NSOrderedSet)

}
