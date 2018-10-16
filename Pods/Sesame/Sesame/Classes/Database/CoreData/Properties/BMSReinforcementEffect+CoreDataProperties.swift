//
//  BMSReinforcementEffect+CoreDataProperties.swift
//  
//
//  Created by Akash Desai on 10/2/18.
//
//

import Foundation
import CoreData

extension BMSReinforcementEffect {

    @nonobjc public class func fetch() -> NSFetchRequest<BMSReinforcementEffect> {
        return NSFetchRequest<BMSReinforcementEffect>(entityName: "BMSReinforcementEffect")
    }

    class func create(in context: NSManagedObjectContext) -> BMSReinforcementEffect? {
        guard let entity = NSEntityDescription.entity(forEntityName: "BMSReinforcementEffect", in: context) else {
            return nil
        }
        return BMSReinforcementEffect(entity: entity, insertInto: context)
    }

    @NSManaged public var reinforcement: BMSReinforcement
    @NSManaged public var attributes: NSSet

}

// MARK: Generated accessors for attributes
extension BMSReinforcementEffect {

    @objc(addAttributesObject:)
    @NSManaged public func addToAttributes(_ value: BMSReinforcementEffectAttribute)

    @objc(removeAttributesObject:)
    @NSManaged public func removeFromAttributes(_ value: BMSReinforcementEffectAttribute)

    @objc(addAttributes:)
    @NSManaged public func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged public func removeFromAttributes(_ values: NSSet)

}
