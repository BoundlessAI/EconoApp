//
//  BMSReinforcement+CoreDataProperties.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

extension BMSReinforcement {

    @nonobjc class func request() -> NSFetchRequest<BMSReinforcement> {
        return NSFetchRequest<BMSReinforcement>(entityName: "BMSReinforcement")
    }

    class func create(in context: NSManagedObjectContext) -> BMSReinforcement? {
        guard let entity = NSEntityDescription.entity(forEntityName: "BMSReinforcement", in: context) else {
            return nil
        }
        return BMSReinforcement(entity: entity, insertInto: context)
    }

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var idx: Int32
    @NSManaged var cartridge: BMSCartridge
    @NSManaged var event: BMSEvent?

}
