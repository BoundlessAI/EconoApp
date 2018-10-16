//
//  BMSReinforcement+CoreDataClass.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

@objc(BMSReinforcement)
public class BMSReinforcement: NSManagedObject {

    @objc public static let NeutralName = "NEUTRAL_RESP"

}

extension BMSReinforcement {
    class func insert(context: NSManagedObjectContext, cartridge: BMSCartridge, id: String, name: String, idx: Int32) -> BMSReinforcement? {
        var value: BMSReinforcement?
        context.performAndWait {
            if let reinforcement = BMSReinforcement.create(in: context) {
                reinforcement.id = id
                reinforcement.name = name
                reinforcement.idx = idx
                cartridge.addToReinforcements(reinforcement)
                do {
                    try context.save()
                } catch let error as NSError {
                    BMSLog.error("Could not insert. \(error)")
                }
                value = reinforcement
            }
        }
        return value
    }
}
