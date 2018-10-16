//
//  Sesame.swift
//  Sesame
//
//  Created by Akash Desai on 7/23/18.
//

import UIKit
import CoreData

@objc
public protocol SesameReinforcementDelegate: class {

    /// Override this method to receive reinforcements!
    /// Set this object as the delegate of the Sesame object from your AppDelegate
    ///
    /// - Parameters:
    ///   - app: The Sesame app
    ///   - reinforcement: A string representing the reinforcement effect configured on the web dashboard
    ///   - options: A dictionary with any additional options configured on the web dashboard
    func reinforce(sesame: Sesame, effectViewController: BMSEffectViewController)
}

@objc
public class Sesame: NSObject {

    @objc public static var shared: Sesame?

    /// If the delegate is not set, the reinforcement effect will affect the whole screen
    @objc public weak var reinforcementDelegate: SesameReinforcementDelegate?

    /// The effect is shown using the custom reinforcementDelegate or the top UIWindow
    fileprivate var _reinforcementEffect: ReinforcementEffect? {
        didSet {
            if let reinforcementEffect = _reinforcementEffect {
                DispatchQueue.main.async {
                    guard let delegate = self.reinforcementDelegate
                        ?? UIWindow.topWindow?.rootViewController
                        else { return }
                    let effectViewController = BMSEffectViewController()
                    effectViewController.reinforcement = reinforcementEffect
                    delegate.reinforce(sesame: self, effectViewController: effectViewController)
                }
                _reinforcementEffect = nil
            }
        }
    }

    var api: APIClient
    let coreDataManager: CoreDataManager

    @objc public var appLifecycleTracker: BMSAppLifecycle
    var trackingOptions: BMSEventMetadataOptions
    let appId: String

    @objc
    public init(appId: String, auth: String, versionId: String?, userId: String) {
        self.api = APIClient()
        self.coreDataManager = CoreDataManager()
        self.trackingOptions = .standard()
        self.appLifecycleTracker = BMSAppLifecycle()
        self.appId = appId

        super.init()

        coreDataManager.newContext { context in
            if let appState = BMSAppState.fetch(context: context, appId: appId) ??
                BMSAppState.insert(context: context, appId: appId, auth: auth, versionId: versionId) {
                if appState.auth != auth {
                    // when switching auth keys clear app state and erase users
                    BMSAppState.delete(context: context, appId: appId)
                    BMSUser.delete(context: context)
                    _ = BMSAppState.insert(context: context, appId: appId, auth: auth, versionId: versionId)
                }
            }
            setUserId(context, userId)
        }

        appLifecycleTracker.listener = self
    }

    var eventUploadCount: Int = 20
    var eventUploadPeriod: TimeInterval = 30

    fileprivate var uploadScheduled = false
}

// MARK: - Public Methods

public extension Sesame {

    @objc
    public func setUserId(_ userId: String?) {
        setUserId(coreDataManager.newContext(), userId)
    }

    internal func setUserId( _ context: NSManagedObjectContext, _ userId: String?) {
        context.performAndWait {
            guard let appState = BMSAppState.fetch(context: context, appId: appId) else {
                BMSLog.error("setUserId without an appState")
                return
            }
            if let userId = userId {
                guard let user = BMSUser.fetch(context: context, id: userId) ??
                    BMSUser.insert(context: context, id: userId) else {
                        BMSLog.error("Could not find or insert user")
                        return
                }
                appState.user = user
            } else {
                appState.user = nil
            }
            do {
                try context.save()
                coreDataManager.save()
            } catch {
                BMSLog.error(error)
            }
            BMSLog.info("set userId:\(String(describing: userId))")
        }
    }

    @objc
    public func getUserId() -> String? {
        return getUserId(nil)
    }

    internal func getUserId(_ context: NSManagedObjectContext?) -> String? {
        var userId: String?
        let context = context ?? coreDataManager.newContext()
        context.performAndWait {
            userId = BMSAppState.fetch(context: context, appId: appId)?.user?.id
        }
        BMSLog.verbose("got userId:\(String(describing: userId))")
        return userId
    }

    //swiftlint:disable:next function_body_length
    public func addEvent(context: NSManagedObjectContext? = nil, actionName: String, metadata: [String: Any] = [:], reinforce: Bool = false) {
        var reinforcementName: String?
        var eventCount = 0
        let context = context ?? coreDataManager.newContext()
        context.performAndWait {
            guard let appState = BMSAppState.fetch(context: context, appId: appId),
                let user = appState.user
                else { return }
            var metadata = metadata
            trackingOptions.annotate(&metadata)
            metadata[BMSSessionId.TimeElapsedName] = appLifecycleTracker.sessionId?.timeElapsed()
            guard let event = BMSEvent.insert(context: context,
                                              userId: user.id,
                                              actionName: actionName,
                                              sessionId: appLifecycleTracker.sessionId as NSNumber?,
                                              metadata: metadata) else { return }
            if reinforce,
                let reinforcedAction = appState.reinforcedActions?.filter({$0["name"] as? String == actionName}).first,
                let actionId = reinforcedAction["id"] as? String,
                let reinforcement = BMSCartridge.fetch(context: context,
                                                       userId: user.id,
                                                       actionId: actionId)?.first?
                    .nextReinforcement
                    ?? BMSCartridge.insert(context: context,
                                           userId: user.id,
                                           actionId: actionId,
                                           cartridgeId: BMSCartridge.NeutralCartridgeId)?
                        .nextReinforcement {
                event.reinforcement = reinforcement
                reinforcementName = reinforcement.name
            }

            eventCount = BMSEvent.count(context: context, userId: user.id) ?? 0
            BMSLog.info("Added event:\(actionName) metadata:\(metadata) for userId:\(user.id)")
            BMSLog.info("Total events for user:#\(eventCount)")
            do {
                try context.save()
                coreDataManager.save()
            } catch {
                BMSLog.error(error)
            }
        }

        if let reinforcementName = reinforcementName {
            BMSLog.info(confirmed: "Reinforcement:\(reinforcementName)")
            _reinforcementEffect = (reinforcementName, [:])
            sendReinforce(context: context)
        } else if eventCount >= eventUploadCount {
            sendReinforce(context: context)
        }
    }

    @objc
    public func eventCount() -> Int {
        let context = coreDataManager.newContext()
        return BMSEvent.count(context: context) ?? 0
    }

    @objc
    public func tracking(option: BMSEventMetadataOption, disabled: Bool) {
        tracking(option: option, enabled: !disabled)
    }

    @objc
    public func tracking(option: BMSEventMetadataOption, enabled: Bool) {
        enabled ? trackingOptions.enable(option) : trackingOptions.disable(option)
    }
}

// MARK: - App Open Reinforcement

extension Sesame: BMSAppLifecycleListener {

    func appLifecycleSessionDidStart(_ appLifecycle: BMSAppLifecycle, lastSession: BMSSessionId?) {
        addEvent(actionName: BMSSessionId.StartName)
    }

    func appLifecycleSessionAppDidOpen(_ appLifecycle: BMSAppLifecycle, reinforceable: Bool) {
        guard let appOpenAction = appLifecycle.appOpenAction else { return }
        addEvent(actionName: BMSSessionId.AppOpenName)
        addEvent(actionName: BMSEvent.AppOpenName,
                 metadata: appOpenAction.metadata,
                 reinforce: reinforceable)
    }

    func appLifecycleSessionInterrupetionWillStart(_ appLifecycle: BMSAppLifecycle) {
        addEvent(actionName: BMSSessionId.InterruptionStartName)
    }

    func appLifecycleSessionInterrupetionDidEnd(_ appLifecycle: BMSAppLifecycle) {
        addEvent(actionName: BMSSessionId.InterruptionEndName)
    }

    func appLifecycleSessionAppWillClose(_ appLifecycle: BMSAppLifecycle) {
        addEvent(actionName: BMSSessionId.AppCloseName)
    }

    func appLifecycleSessionWillEnd(_ appLifecycle: BMSAppLifecycle) {
        addEvent(actionName: BMSSessionId.EndName)
    }

}

// MARK: - HTTP Methods

extension Sesame {

    public func sendBoot(completion: @escaping (Bool) -> Void = {_ in}) {
        coreDataManager.newContext { context in
            guard let appState = BMSAppState.fetch(context: context, appId: appId)
                else {
                    completion(false)
                    return
            }
            let payload = api.createPayload(appId: appId,
                                            versionId: appState.versionId,
                                            revision: Int(appState.revision),
                                            primaryIdentity: nil)

            api.post(endpoint: .boot, auth: appState.basicAuth, jsonBody: payload) { response in
                guard let response = response,
                    response["errors"] == nil else {
                        completion(false)
                        return
                }
                self.coreDataManager.newContext { context in
                    guard let appState = BMSAppState.fetch(context: context, appId: self.appId) else {
                        completion(false)
                        return
                    }
                    if let revision = response["revision"] as? Int {
                        appState.revision = Int64(revision)
                    }
                    if let config = response["config"] as? [String: Any] {
                        if let reinforcedActions = config["reinforcedActions"] as? [[String: Any]] {
                            appState.effectDetailsAsDictionary = ["reinforcedActions": reinforcedActions]
                        }
                    }
                    do {
                        if context.hasChanges {
                            try context.save()
                            self.coreDataManager.save()
                        }
                    } catch {
                        BMSLog.error(error)
                    }
                }
                completion(true)
                self.sendReinforce(context: self.coreDataManager.newContext())
            }
        }
    }

    //swiftlint:disable:next cyclomatic_complexity function_body_length
    func sendReinforce(context: NSManagedObjectContext, completion: @escaping (Bool) -> Void = {_ in}) {
        context.performAndWait {
            guard !uploadScheduled else { return }
            uploadScheduled = true
            guard let appState = BMSAppState.fetch(context: context, appId: appId),
                let user = appState.user,
                let allActionIds = appState.actionIds
                else {
                    uploadScheduled = false
                    return
            }
            let actionIds = BMSCartridge.needsRefresh(context: context, userId: user.id, actionIds: allActionIds)
            guard !actionIds.isEmpty else {
                uploadScheduled = false
                return
            }
            var payload = api.createPayload(appId: appState.appId,
                                            versionId: appState.versionId,
                                            revision: Int(appState.revision),
                                            primaryIdentity: user.id)
            payload["reports"] = {
                var tracks = [[String: Any]]()
                if let reports = appState.user?.reports.allObjects as? [BMSReport] {
                    for report in reports {
                        var track = [String: Any]()
                        track["actionId"] = report.actionName
                        track["type"] = report.type.stringValue
                        var events = [[String: Any]]()
                        for case let reportEvent as BMSEvent in report.events {
                            var event = [String: Any]()
                            event["utc"] = reportEvent.utc
                            event["timezoneOffset"] = reportEvent.timezoneOffset
                            event["metadata"] = reportEvent.metadataAsDictionary
                            event["reinforcementDecision"] = reportEvent.reinforcement?.name
                            event["idx"] = reportEvent.reinforcement?.idx
                            events.append(event)
                            context.delete(reportEvent)
                        }
                        track["events"] = events

                        tracks.append(track)
                    }
                    // delete empty cartridges after reinforcements are deleted with events
                    let deletedCartridges = BMSCartridge.deleteStale(context: context, userId: user.id)
                    BMSLog.warning("Deleted \(deletedCartridges) stale cartridges")

                    do {
                        try context.save()
                    } catch {
                        BMSLog.error(error)
                    }
                }
                return tracks
            }()

            payload["refresh"] = {
                var refresh = [[String: Any]]()
                for actionId in actionIds {
                    refresh.append(["actionId": actionId, "size": 5])
                }

                return refresh
            }()

            api.post(endpoint: .reinforce, auth: appState.basicAuth, jsonBody: payload) { response in
                guard let response = response,
                    response["errors"] == nil,
                    let utc = response["utc"] as? Int64 else {
                        BMSLog.error("Bad response")
                        self.uploadScheduled = false
                        completion(false)
                        return
                }
                self.coreDataManager.newContext { context in
                    guard let appState = BMSAppState.fetch(context: context, appId: self.appId),
                        let reinforcedActions = appState.reinforcedActions,
                        let user = appState.user
                        else { return }
                    for cartridgeInfo in response["cartridges"] as? [[String: Any]] ?? [] {
                        BMSLog.warning("Cart info:\(cartridgeInfo as AnyObject)")
                        if let ttl = cartridgeInfo["ttl"] as? Int64,
                            let actionId = cartridgeInfo["actionId"] as? String,
                            let cartridgeId = cartridgeInfo["cartridgeId"] as? String,
                            let reinforcementIds = (cartridgeInfo["reinforcements"] as? [[String: String]])?
                                .compactMap({$0["reinforcementId"]}),
                            let reinforcedAction = reinforcedActions.filter({$0["id"] as? String == actionId}).first,
                            let reinforcements = reinforcedAction["reinforcements"] as? [[String: Any]] {
                            var reinforcementIdsAndNames = [(String, String)]()
                            for id in reinforcementIds {
                                if let reinforcement = reinforcements.filter({$0["id"] as? String == id}).first,
                                    let name = reinforcement["name"] as? String {
                                    reinforcementIdsAndNames.append((id, name))
                                }
                            }
                            BMSCartridge.insert(context: context,
                                                userId: user.id,
                                                actionId: actionId,
                                                cartridgeId: cartridgeId,
                                                utc: utc,
                                                ttl: ttl,
                                                reinforcementIdAndName: reinforcementIdsAndNames)
                        }
                    }
                }
                self.coreDataManager.save()
                self.uploadScheduled = false
                completion(true)
            }
        }
    }
}

//swiftlint:disable:this file_length
