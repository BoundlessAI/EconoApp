//
//  BMSSoundEffect.swift
//  Sesame
//
//  Created by Akash Desai on 11/29/17.
//

import Foundation
import AudioToolbox

class BMSSoundEffect: NSObject {

    fileprivate static let audioQueue = DelayedSerialQueue(delayAfter: 1, dropCollisions: false)

    class func play(_ systemSoundID: SystemSoundID = 0, vibrate: Bool = false) {
        audioQueue.addOperation {
            if systemSoundID != 0 {
                AudioServicesPlaySystemSound(systemSoundID)
            }
            if vibrate {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }

}
