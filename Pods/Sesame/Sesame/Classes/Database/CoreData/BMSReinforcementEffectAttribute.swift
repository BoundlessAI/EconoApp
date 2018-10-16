//
//  BMSReinforcementEffectAttribute.swift
//  
//
//  Created by Akash Desai on 10/2/18.
//
//

import Foundation
import CoreData

@objc(BMSReinforcementEffectAttribute)
public class BMSReinforcementEffectAttribute: NSManagedObject {

    enum Key: String {
        case name, duration
    }

}

extension BMSReinforcementEffectAttribute {
    class func insert(context: NSManagedObjectContext, reinforementEffect: BMSReinforcementEffect, key: String, value: NSObject) -> BMSReinforcementEffectAttribute? {

        var value: BMSReinforcementEffectAttribute?
        context.performAndWait {
            if let attr = BMSReinforcementEffectAttribute.create(in: context) {
                attr.key = key
                attr.value = value
                reinforementEffect.addToAttributes(attr)
                do {
                    try context.save()
                } catch let error as NSError {
                    BMSLog.error(error)
                }
                value = attr
            }
        }
        return value
    }
}
