//
//  BMSSheenEffectView.swift
//  Sesame
//
//  Created by Akash Desai on 7/26/18.
//

import UIKit

@objc
open class BMSSheenEffectView: BMSVisualEffectView {

    public enum WidthToHeightRatio: CGFloat {
        case narrow = 0.333, equal = 1, wide = 1.667
    }

    @IBInspectable @objc
    public var duration: Double = 2
    @IBInspectable @objc
    public var delay: Double = 0
    @IBInspectable @objc
    public var image: UIImage?
    @IBInspectable @objc
    public var widthToHeightRatio: CGFloat = WidthToHeightRatio.wide.rawValue {
        didSet {
            if #available(iOS 9.0, *),
                imageViewWidthConstraint != nil {
                imageViewWidthConstraint?.isActive = false
                imageViewWidthConstraint = imageView?.widthAnchor
                    .constraint(equalTo: self.heightAnchor, multiplier: widthToHeightRatio)
                imageViewWidthConstraint?.isActive = true
                setNeedsLayout()
            }
        }
    }
    @IBInspectable @objc
    public var color: UIColor?
    @IBInspectable @objc
    public var opacityMask: Bool = false
    @IBInspectable @objc
    public var hapticFeedback: Bool = false
    @IBInspectable @objc
    public var systemSound: UInt32 = 0

    public var animationOptions: AnimationOptions = []

    fileprivate var imageViewAnimationStartConstraint: NSLayoutConstraint?
    fileprivate var imageViewAnimationEndConstraint: NSLayoutConstraint?
    fileprivate var imageViewWidthConstraint: NSLayoutConstraint?
    fileprivate var imageView: UIImageView?

    override open func didRotate() {
        if opacityMask && superview != nil {
            mask = superview?.generateMask()
        }
    }

    @objc
    override open func start(completion: @escaping () -> Void = {}) { // swiftlint:disable:this function_body_length
        if image == nil,
            let bundle = Bundle.sesame,
            let image = UIImage(named: "sheen", in: bundle, compatibleWith: nil) {
            self.image = image
        }
        if imageView == nil && image != nil {
            if let color = color {
                image = image?.tint(tintColor: color)
            }
            let imageView = UIImageView(image: image)
            self.imageView = imageView

            imageView.isHidden = true
            self.addSubview(imageView)

            if #available(iOS 9.0, *) {
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: self.topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                    ])
                imageViewWidthConstraint = imageView.widthAnchor.constraint(equalTo: heightAnchor,
                                                                            multiplier: widthToHeightRatio)
                imageViewAnimationStartConstraint = imageView.trailingAnchor.constraint(equalTo: leadingAnchor)
                imageViewAnimationEndConstraint = imageView.leadingAnchor.constraint(equalTo: trailingAnchor)
                imageViewWidthConstraint?.isActive = true
                imageViewAnimationEndConstraint?.isActive = false
                imageViewAnimationStartConstraint?.isActive = true
            }
            layoutIfNeeded()
        }

        guard let imageView = imageView else {
            BMSLog.error("No image set for sheen")
            completion()
            return
        }
        guard imageView.isHidden else {
            BMSLog.error("Sheen is already animating")
            completion()
            return
        }

        if opacityMask {
            mask = superview?.generateMask()
        }

        setNeedsLayout()
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: animationOptions,
                       animations: {
                        imageView.isHidden = false
                        self.imageViewAnimationStartConstraint?.isActive = false
                        self.imageViewAnimationEndConstraint?.isActive = true
                        self.layoutIfNeeded()
                        BMSSoundEffect.play(self.systemSound, vibrate: self.hapticFeedback)
        },
                       completion: { _ in
                        imageView.isHidden = true
                        self.imageViewAnimationEndConstraint?.isActive = false
                        self.imageViewAnimationStartConstraint?.isActive = true
                        self.layoutIfNeeded()
                        completion()
        })
    }

}
