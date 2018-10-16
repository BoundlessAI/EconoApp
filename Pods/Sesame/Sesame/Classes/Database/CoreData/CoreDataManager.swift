//
//  CoreDataManager.swift
//  Sesame
//
//  Created by Akash Desai on 7/29/18.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {

    // MARK: - CoreData Objects

    private lazy var managedObjectModel: NSManagedObjectModel? = {
        if let modelURL = Bundle(for: type(of: self)).url(forResource: "Sesame", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) {
            return model
        }
        return nil
    }()

    private lazy var persistentStoreURL: URL? = {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            return dir.appendingPathComponent("Sesame.sqlite")
        }
        return nil
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        if let model = managedObjectModel,
            let persistentStoreURL = persistentStoreURL {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                   configurationName: nil,
                                                   at: persistentStoreURL,
                                                   options: [NSInferMappingModelAutomaticallyOption: true,
                                                             NSMigratePersistentStoresAutomaticallyOption: true])
                return coordinator
            } catch {
                BMSLog.error(error)
            }
        }
        return nil
    }()

    private lazy var managedObjectContext: NSManagedObjectContext? = {
        guard let coordinator = persistentStoreCoordinator else { return nil }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSRollbackMergePolicy
        return managedObjectContext
    }()

    @discardableResult
    func newContext(completion: (NSManagedObjectContext) -> Void = {_ in}) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = managedObjectContext
        context.performAndWait {
            completion(context)
            if context.hasChanges {
                try? context.save()
            }
        }
        return context
    }

    // MARK: - Save & Delete Methods

    func save() {
        managedObjectContext?.performAndWait {
            if managedObjectContext?.hasChanges ?? false {
                do {
                    try managedObjectContext?.save()
                } catch {
                    BMSLog.error("\(error)")
                }
            }
        }
    }

    func deleteObjects() {
        managedObjectContext?.performAndWait {
            let rootModels = [BMSReinforcement.self,
                              BMSCartridge.self,
                              BMSEvent.self,
                              BMSReport.self,
                              BMSUser.self,
                              BMSAppState.self]
            for model in rootModels {
                let request = NSFetchRequest<NSManagedObject>(entityName: model.description())
                do {
                    if let objects = try managedObjectContext?.fetch(request) {
                        for object in objects {
                            managedObjectContext?.delete(object)
                        }
                    }
                } catch {
                    BMSLog.error(error)
                }
            }
            save()
        }
    }

}

extension Optional where Wrapped == String {
    var predicateValue: String {
        return self == nil ? "nil" : "'\(self!)'"
    }
}

extension Optional where Wrapped == [String: Any] {
    static func from(string: String) -> [String: Any]? {
        if let data = string.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? [String: Any] {
            return dict
        }
        return nil
    }

    func toString() -> String? {
        if let dict = self,
            let data = try? JSONSerialization.data(withJSONObject: dict),
            let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }
}
