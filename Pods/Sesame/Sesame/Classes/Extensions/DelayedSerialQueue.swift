//
//  DelayedSerialQueue.swift
//  Sesame
//
//  Created by Akash Desai on 3/14/18.
//

import Foundation

internal class DelayedSerialQueue: OperationQueue {

    var delayBefore: UInt32 = 0
    var delayAfter: UInt32 = 0
    var dropCollisions = false

    init(delayBefore: UInt32 = 0, delayAfter: UInt32 = 0, dropCollisions: Bool = false, qualityOfService: QualityOfService? = nil) {
        self.delayBefore = delayBefore
        self.delayAfter = delayAfter
        self.dropCollisions = dropCollisions
        super.init()
        if let qos = qualityOfService {
            self.qualityOfService = qos
        }

        maxConcurrentOperationCount = 1
    }

    override func addOperation(_ block: @escaping () -> Void) {
        if dropCollisions && operationCount != 0 { return }

        super.addOperation {
            if self.dropCollisions && self.operationCount != 1 { return }

            if self.delayBefore != 0 {
                sleep(self.delayBefore)
            }

            block()

            if self.delayAfter != 0 {
                sleep(self.delayAfter)
            }
        }
    }

}
