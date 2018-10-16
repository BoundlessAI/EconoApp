//
//  BMSAppLifecycleTracker.swift
//  Sesame
//
//  Created by Akash Desai on 9/13/18.
//

import UIKit

protocol BMSAppLifecycleListener: class {
    func appLifecycleSessionDidStart(_ appLifecycle: BMSAppLifecycle, lastSession: BMSSessionId?)
    func appLifecycleSessionAppDidOpen(_ appLifecycle: BMSAppLifecycle, reinforceable: Bool)
    func appLifecycleSessionInterrupetionWillStart(_ appLifecycle: BMSAppLifecycle)
    func appLifecycleSessionInterrupetionDidEnd(_ appLifecycle: BMSAppLifecycle)
    func appLifecycleSessionAppWillClose(_ appLifecycle: BMSAppLifecycle)
    func appLifecycleSessionWillEnd(_ appLifecycle: BMSAppLifecycle)
}

open class BMSAppLifecycle: NSObject {

    weak var listener: BMSAppLifecycleListener?

    var appOpenAction: BMSAppOpenAction? {
        willSet {
            if appOpenAction != nil {
                listener?.appLifecycleSessionAppWillClose(self)
                sessionId = nil
            }
        }
        didSet {
            if let appOpenAction = appOpenAction {
                sessionId = .new
                let reinforce: Bool
                switch appOpenAction.cueCategory {
                case .external, .internal:
                    reinforce = true
                case .synthetic:
                    reinforce = false
                }
                listener?.appLifecycleSessionAppDidOpen(self, reinforceable: reinforce)
            }
        }
    }

    var sessionId: BMSSessionId? {
        willSet {
            if sessionId != nil {
                listener?.appLifecycleSessionWillEnd(self)
            }
        }
        didSet {
            if sessionId != nil {
                listener?.appLifecycleSessionDidStart(self, lastSession: oldValue)
            }
        }
    }

    var appIsInterrupted = false {
        didSet (appWasInterrupted) {
            switch (appWasInterrupted, appIsInterrupted) {
            case (false, true): listener?.appLifecycleSessionInterrupetionWillStart(self)
            case (true, false): listener?.appLifecycleSessionInterrupetionDidEnd(self)
            default: break
            }
        }
    }

    fileprivate var notificationsToRegister = [
        UIApplication.didFinishLaunchingNotification,
        UIApplication.willTerminateNotification,
        UIApplication.didBecomeActiveNotification,
        UIApplication.willResignActiveNotification,
        UIApplication.didEnterBackgroundNotification
    ]

    public override init() {
        super.init()
        for notification in notificationsToRegister {
            NotificationCenter.default.addObserver(self, selector: #selector(receive(_:)),
                                                   name: notification,
                                                   object: nil)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func receive(_ notification: Notification) {
        BMSLog.verbose("Got notification:\(notification.name) info:\(notification.userInfo as AnyObject)")
        switch notification.name {
        case UIApplication.didFinishLaunchingNotification:  didLaunch(notification.userInfo)
        case UIApplication.willTerminateNotification:       didTerminate()
        case UIApplication.didBecomeActiveNotification:     didBecomeActive()
        case UIApplication.willResignActiveNotification:    willResignActive()
        case UIApplication.didEnterBackgroundNotification:  didEnterBackground()
        default: break
        }
    }
}

// MARK: - Tracked Events

extension BMSAppLifecycle {

    // MARK: - UIApplicationDidFinishLaunching

    @objc
    public func didLaunch(_ userInfo: [AnyHashable: Any]?) {
        if let sesame = listener as? Sesame {
            sesame.sendBoot()
        }
        if #available(iOS 9.0, *),
            userInfo?[UIApplication.LaunchOptionsKey.shortcutItem] != nil {
            didPerformShortcut()
        } else if userInfo?[UIApplication.LaunchOptionsKey.sourceApplication] != nil
            || userInfo?[UIApplication.LaunchOptionsKey.url]  != nil {
            didOpenURL()
        } else if userInfo?[UIApplication.LaunchOptionsKey.remoteNotification] != nil
            || userInfo?[UIApplication.LaunchOptionsKey.localNotification] != nil {
            didReceiveNotification()
        }
    }

    // MARK: App Open from Shortcut

    @objc
    public func didPerformShortcut() {
        if appOpenAction == nil {
            appOpenAction = BMSAppOpenAction(source: .shortcut)
        }
    }

    // MARK: App Open from Deep Link

    @objc
    public func didOpenURL() {
        if appOpenAction == nil {
            appOpenAction = BMSAppOpenAction(source: .deepLink)
        }
    }

    // MARK: App Open from Notifications

    @objc
    public func didReceiveNotification() {
        if appOpenAction == nil {
            appOpenAction = BMSAppOpenAction(source: .notification)
        }
    }

    // MARK: - UIApplicationWillTerminate

    @objc
    public func didTerminate() {
        appOpenAction = nil
    }

    // MARK: - UIApplicationDidBecomeActive

    @objc
    public func didBecomeActive() {
        if appOpenAction == nil {
            appOpenAction = BMSAppOpenAction(source: .default)
        }
        appIsInterrupted = false
    }

    // MARK: - UIApplicationWillResignActive

    @objc
    public func willResignActive() {
        appIsInterrupted = true
    }

    // MARK: - UIApplicationDidEnterBackground

    @objc
    public func didEnterBackground() {
        appOpenAction = nil
    }
}
