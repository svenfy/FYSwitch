//
//  FY2DRotateKnob.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/17.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import ReactiveSwift

class FY2DRotateKnob: UIView, IKnob {
    lazy var onButton: UIButton! = {
        let btn = generateButton()
        btn.transform = CGAffineTransform.init(rotationAngle: .pi)
        btn.alpha = 0
        addSubview(btn)
        return btn;
    }()
    lazy var offButton: UIButton! = {
        let btn = generateButton()
        insertSubview(btn, at: 0)
        return btn;
    }()
    
    //MARK: ------------ IKnob ------------
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<String?>.init(object: backSwitch, keyPath: #keyPath(FYImageTextSwitch.knobOnText)).producer.startWithValues { [unowned self] (title) -> Void in
                self.onButton.setTitle(title, for: .disabled)
            }
            Property<String?>.init(object: backSwitch, keyPath: #keyPath(FYImageTextSwitch.knobOffText)).producer.startWithValues { [unowned self] (title) -> Void in
                self.offButton.setTitle(title, for: .disabled)
            }
            Property<UIImage?>.init(object: backSwitch, keyPath: #keyPath(FYImageTextSwitch.knobOnImage)).producer.startWithValues { (image) in
                self.onButton.setImage(image, for: .disabled)
            }
            Property<UIImage?>.init(object: backSwitch, keyPath: #keyPath(FYImageTextSwitch.knobOffImage)).producer.startWithValues { (image) in
                self.offButton.setImage(image, for: .disabled)
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOnBgColor)).producer.startWithValues { (color) in
                self.onButton.backgroundColor = color
                self.onButton.layer.shadowColor = color?.cgColor
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOffBgColor)).producer.startWithValues { (color) in
                self.offButton.backgroundColor = color
                self.offButton.layer.shadowColor = color?.cgColor
            }
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        bounds = CGRect(origin: .zero,
                       size: CGSize(width: boundary.height, height: boundary.height))
        if self.onButton.bounds.height != bounds.height {
            onButton.frame = self.bounds
            offButton.frame = self.bounds
            onButton.layer.cornerRadius = bounds.height/2
            offButton.layer.cornerRadius = onButton.layer.cornerRadius
        }
        toggle(to: backSwitch.on, animated: false)
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        let (showView, hideView): (UIButton, UIButton) = isOn ? (onButton!, offButton!) : (offButton!, onButton!)
        bringSubview(toFront: showView)

        if animated {
            UIView.animate(withDuration: backSwitch.duration, animations: { [unowned self] in
                self.center = CGPoint(x: isOn ? self.backSwitch.bounds.width - self.backSwitch.bounds.height/2 : self.backSwitch.bounds.height/2, y: self.backSwitch.bounds.height/2)
                self.transform = CGAffineTransform(rotationAngle: isOn ? CGFloat.pi : -CGFloat.pi*2)

                showView.alpha = 1
                hideView.alpha = 0

                }, completion:nil)
        } else {
            self.center = CGPoint(x: isOn ? self.backSwitch.bounds.width - self.backSwitch.bounds.height/2 : self.backSwitch.bounds.height/2, y: self.backSwitch.bounds.height/2)
            self.transform = CGAffineTransform(rotationAngle: isOn ? CGFloat.pi : -CGFloat.pi*2)

            showView.alpha = 1
            hideView.alpha = 0
        }
    }
    
    func generateButton() -> UIButton {
        let button = UIButton(frame: frame)
        button.isEnabled = false
        button.layer.cornerRadius = frame.height/2
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        return button
    }
}
