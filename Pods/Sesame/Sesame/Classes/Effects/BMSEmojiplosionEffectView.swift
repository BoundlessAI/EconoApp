//
//  BMSEmojiplosionEffectView.swift
//  Sesame
//
//  Created by Akash Desai on 9/15/18.
//

import UIKit

@objc
open class BMSEmojiplosionEffectView: BMSVisualEffectView {

    public var location: (CGFloat, CGFloat) = (0.5, 0.5)
    public var image: UIImage? = UIImage(text: "❤️")
    public var scale: CGFloat = 0.6
    public var scaleSpeed: CGFloat = 0.2
    public var scaleRange: CGFloat = 0.2
    public var lifetime: Float = 3.0
    public var lifetimeRange: Float = 0.5
    public var fadeout: Float = -1
    public var rate: Float = 4.0
    public var duration: Double = 1.0
    public var velocity: CGFloat = -50
    public var xAcceleration: CGFloat = 0
    public var yAcceleration: CGFloat = -150
    public var angle: CGFloat = -90
    public var range: CGFloat = 45
    public var spin: CGFloat = 0
    public var hapticFeedback: Bool = false
    public var systemSound: UInt32 = 1007

    @objc
    public override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = false
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func start(completion: @escaping () -> Void = {}) {
        guard let cgImage = image?.cgImage else {
            BMSLog.warning("Image not set")
            completion()
            return
        }

        DispatchQueue.main.async {
            let emitter = CAEmitterLayer()
            emitter.emitterPosition = self.bounds.pointWithMargins(x: self.location.0, y: self.location.1)
            emitter.beginTime = CACurrentMediaTime() - 0.9

            let cell = CAEmitterCell()
            cell.contents = cgImage
            cell.birthRate = self.rate
            cell.lifetime = self.lifetime
            cell.lifetimeRange = self.lifetimeRange
            cell.spin = self.spin.degreesToRadians()
            cell.spinRange = cell.spin / 8
            cell.velocity = self.velocity
            cell.velocityRange = cell.velocity / 3
            cell.xAcceleration = self.xAcceleration
            cell.yAcceleration = self.yAcceleration
            cell.scale = self.scale
            cell.scaleSpeed = self.scaleSpeed
            cell.scaleRange = self.scaleRange
            cell.emissionLongitude = self.angle.degreesToRadians()
            cell.emissionRange = self.range.degreesToRadians()
            if self.fadeout > 0 {
                cell.alphaSpeed = -1.0 / self.fadeout
                cell.color = cell.color?.copy(alpha: CGFloat(self.lifetime / self.fadeout))
            } else if self.fadeout < 0 { // fadein
                cell.alphaSpeed = 1.0 / -self.fadeout
                cell.color = cell.color?.copy(alpha: 0)
            }
            emitter.emitterCells = [cell]

            self.layer.addSublayer(emitter)
            BMSLog.verbose("💥 Emojiplosion on <\(NSStringFromClass(type(of: self)))> at <\(emitter.emitterPosition)>!")
            BMSSoundEffect.play(self.systemSound, vibrate: self.hapticFeedback)
            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
                emitter.birthRate = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(self.lifetime + self.lifetimeRange)) {
                    emitter.removeFromSuperlayer()
                    BMSLog.verbose("💥 Emojiplosion done")
                    completion()
                }
            }
        }
    }

}
