//
//  BMSCartridge+CoreDataClass.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

@objc(BMSCartridge)
class BMSCartridge: NSManagedObject {

    static let NeutralCartridgeId = "CLIENT_NEUTRAL"

    var nextReinforcement: BMSReinforcement? {
        guard let context = managedObjectContext else { return nil }
        var value: BMSReinforcement?
        context.performAndWait {
//            let cartridgeCount = BMSCartridge.fetch(context: context, userId: user.id)?.compactMap({$0})
//            BMSLog.warning("Total Cartridges: \(cartridgeCount as AnyObject)")
            if (utc + ttl) >= Int64(1000 * Date().timeIntervalSince1970),
                let reinforcements = reinforcements.array as? [BMSReinforcement],
                let reinforcement = reinforcements.filter({$0.event == nil}).first {
                value = reinforcement
                BMSLog.warning("Available Reinforcements:\(reinforcements.filter({$0.event == nil}).count)")
            } else if cartridgeId == BMSCartridge.NeutralCartridgeId,
                let reinforcement = BMSReinforcement.insert(context: context,
                                                            cartridge: self,
                                                            id: BMSReinforcement.NeutralName,
                                                            name: BMSReinforcement.NeutralName,
                                                            idx: Int32(reinforcements.count)
                                                            ) {
                BMSLog.warning("Cartridge is empty. Delivering default reinforcement.")
                value = reinforcement
            }
        }
        return value
    }

}

extension BMSCartridge {

    class func needsRefresh(context: NSManagedObjectContext, userId: String, actionIds: [String]) -> [String] {
        var value = [String]()
        context.performAndWait {
            let now = Int64(Date().timeIntervalSince1970 * 1000)
            for actionId in actionIds {
                guard let cartridge = BMSCartridge.fetch(context: context,
                                                         userId: userId,
                                                         actionId: actionId)?
                    .first else {
                        value.append(actionId)
                        continue
                }
                if cartridge.cartridgeId == BMSCartridge.NeutralCartridgeId ||
                    cartridge.utc + cartridge.ttl < now ||
                    cartridge.reinforcements.filter({($0 as? BMSReinforcement)?.event == nil}).isEmpty {
                    value.append(actionId)
                    continue
                }
            }
        }
        return value
    }

    class func fetch(context: NSManagedObjectContext, userId: String) -> [BMSCartridge]? {
        var value: [BMSCartridge]?
        context.performAndWait {
            let request = BMSCartridge.request()
            request.predicate = NSPredicate(format: "\(#keyPath(BMSCartridge.user.id)) == '\(userId)'")
            do {
                value = try context.fetch(request)
            } catch let error as NSError {
                BMSLog.error("Could not fetch. \(error)")
            }
        }
        return value
    }

    class func fetch(context: NSManagedObjectContext, userId: String, actionId: String) -> [BMSCartridge]? {
        var value: [BMSCartridge]?
        context.performAndWait {
            let request = BMSCartridge.request()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(BMSCartridge.user.id)) == '\(userId)'"),
                NSPredicate(format: "\(#keyPath(BMSCartridge.actionId)) == '\(actionId)'")
                ])
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(BMSCartridge.utc), ascending: false)]
            do {
                value = try context.fetch(request)
            } catch let error as NSError {
                BMSLog.error("Could not fetch. \(error)")
            }
        }
        return value
    }

    @discardableResult
    class func deleteStale(context: NSManagedObjectContext, userId: String) -> Int {
        var value = 0
        context.performAndWait {
            let now = Int64(Date().timeIntervalSince1970 * 1000)
            for cartridge in fetch(context: context, userId: userId) ?? [] {
                if (cartridge.utc + cartridge.ttl) < now {
                    if cartridge.reinforcements.array.filter({($0 as? BMSReinforcement)?.event != nil}).isEmpty {
                        context.delete(cartridge)
                        value += 1
                    }
                } else if cartridge.reinforcements.array.isEmpty {
                    context.delete(cartridge)
                    value += 1
                }
            }
        }
        return value
    }

    @discardableResult
    class func insert(context: NSManagedObjectContext, userId: String, actionId: String, cartridgeId: String = BMSCartridge.NeutralCartridgeId, utc: Int64 = Int64(Date().timeIntervalSince1970 * 1000), ttl: Int64 = 0, reinforcementIdAndName: [(String, String)] = []) -> BMSCartridge? {
        var value: BMSCartridge?
        context.performAndWait {
            if let user = BMSUser.fetch(context: context, id: userId),
                let cartridge = BMSCartridge.create(in: context) {
                cartridge.user = user
                cartridge.actionId = actionId
                cartridge.cartridgeId = cartridgeId
                cartridge.utc = utc
                cartridge.ttl = ttl
                var idx: Int32 = 0
                _ = reinforcementIdAndName.compactMap({
                    _ = BMSReinforcement.insert(context: context, cartridge: cartridge, id: $0.0, name: $0.1, idx: idx)
                    idx += 1
                })
                BMSLog.warning("Inserted cartridge with :\(cartridge.reinforcements.count) reinforcements")
                do {
                    try context.save()
                } catch let error as NSError {
                    BMSLog.error("Could not insert. \(error)")
                }
                value = cartridge
            }
        }
        return value
    }

}
