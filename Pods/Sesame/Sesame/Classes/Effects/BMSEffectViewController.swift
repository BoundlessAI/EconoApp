//
//  BMSEffectViewController.swift
//  Sesame
//
//  Created by Akash Desai on 9/19/18.
//

import UIKit

typealias ReinforcementEffect = (String, [String: Any])

open class BMSEffectViewController: UIViewController {

    var effectView: BMSVisualEffectView?
    var reinforcement: ReinforcementEffect?

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false

        guard let reinforcement = reinforcement else { return }
        effectView = {
            switch reinforcement.0 {
            case "confetti":        return BMSConfettiEffectView()
            case "sheen":           return BMSSheenEffectView()
            case "emojisplosion":   return BMSEmojiplosionEffectView()
            default:                return nil
            }
        }()
    }

    func showEffect(_ completion: @escaping (Bool) -> Void = {_ in}) {
        DispatchQueue.main.async {
            guard let effectView = self.effectView,
                effectView.superview == nil else {
                    completion(false)
                    return
            }
            self.view.addSubview(effectView)
            effectView.constrainToSuperview()
            effectView.start {
                DispatchQueue.main.async {
                    effectView.removeFromSuperview()
                    completion(true)
                }
            }
        }
    }
}
