//
//  BMSIntegrationState+CoreDataClass.swift
//  
//
//  Created by Akash Desai on 9/26/18.
//
//

import Foundation
import CoreData

@objc(BMSAppState)
class BMSAppState: NSManagedObject {

    var basicAuth: HTTPClient.AuthorizationHeader {
        return .basic(appId, auth)
    }

}

extension BMSAppState {

    class func fetch(context: NSManagedObjectContext, appId: String) -> BMSAppState? {
        var value: BMSAppState?
        context.performAndWait {
            let request = BMSAppState.request()
            request.predicate = NSPredicate(format: "\(#keyPath(BMSAppState.appId)) == '\(appId)'")
            request.fetchLimit = 1
            do {
                value = try context.fetch(request).first
            } catch let error as NSError {
                BMSLog.error("Could not fetch \(error)")
            }
        }
        return value
    }

    @discardableResult
    class func delete(context: NSManagedObjectContext, appId: String) -> Int? {
        var count: Int?
        context.performAndWait {
            let request = BMSAppState.request()
            request.predicate = NSPredicate(format: "\(#keyPath(BMSAppState.appId)) == '\(appId)'")
            do {
                count = try context.fetch(request).map({context.delete($0)}).count
                if context.hasChanges {
                    try context.save()
                }
            } catch let error as NSError {
                BMSLog.error("Could not fetch or insert. \(error)")
            }
        }
        return count
    }

    class func insert(context: NSManagedObjectContext, appId: String, auth: String, versionId: String? = nil, configId: String? = nil) -> BMSAppState? {
        var value: BMSAppState?
        context.performAndWait {
            if let appState = BMSAppState.create(in: context) {
                appState.appId = appId
                appState.auth = auth
                appState.versionId = versionId
                appState.configId = configId
                do {
                    try context.save()
                } catch let error as NSError {
                    BMSLog.error("Could not insert. \(error)")
                }
                value = appState
            }
        }
        return value
    }

}
