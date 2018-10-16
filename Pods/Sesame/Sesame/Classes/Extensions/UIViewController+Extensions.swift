//
//  UIViewController+Extensions.swift
//  Sesame
//
//  Created by Akash Desai on 9/27/18.
//

import Foundation
import UIKit

extension UIViewController: SesameReinforcementDelegate {

    public func reinforce(sesame: Sesame, effectViewController: BMSEffectViewController) {
        DispatchQueue.main.async {
            // implement this UIViewController as a container for the effect
            self.addChild(effectViewController)
            effectViewController.view.frame = self.view.bounds
            self.view.addSubview(effectViewController.view)
            effectViewController.didMove(toParent: self)
            effectViewController.showEffect { _ in
                // remove the effect from the container when done
                effectViewController.willMove(toParent: nil)
                effectViewController.view.removeFromSuperview()
                effectViewController.removeFromParent()
            }
        }
    }

}
