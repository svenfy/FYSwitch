//
//  FYLineStrokeKnob.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/18.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import ReactiveSwift
import pop

class FYLineStrokeKnob: UIView, IKnob {
    lazy var line1: UIView! = { // 较短的那条
        return generateLine(withRotationAngle: .pi*3/4)
    }()
    lazy var line2: UIView! = { // 较长的那条
        return generateLine(withRotationAngle: .pi/4)
    }()
    
    //MARK: ------------ IKnob ------------
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOnBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                if self.backSwitch.on {
                    self.backgroundColor = color
                    self.layer.shadowColor = color?.cgColor
                }
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOffBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                if !self.backSwitch.on { self.backgroundColor = color }
            }
        }
    }
    
    func adjustPosition(withBoundary frame: CGRect) {
        if let backSwitch = self.backSwitch {
            let newFrame = CGRect(origin: CGPoint(x: backSwitch.on ? frame.maxX - frame.height : frame.minX, y: frame.minY),
                                  size: CGSize(width: frame.height, height: frame.height))
            if self.frame.height != newFrame.height {
                self.layer.cornerRadius = newFrame.height/2
                self.layer.shadowOffset = CGSize(width: 0, height: -3)
                self.layer.shadowOpacity = 0
            }
            self.frame = newFrame
            toggle(to: backSwitch.on, animated: false)
        }
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        let w = self.backSwitch.bounds.width, h = self.backSwitch.bounds.height
        let rate = bounds.width/140
        
        let kh = bounds.height
        let targetBoundsLine1 = CGRect(x: 0, y: 0, width: 8*rate, height: isOn ? 0.26264*kh : 48*sqrt(2)*rate)
        let targetCenterLine1 = isOn ? CGPoint(x: 0.64*kh, y: 0.39*kh) : CGPoint(x: kh/2, y: kh/2)
        
        let targetBoundsLine2 = CGRect(x: 0, y: 0, width: 8*rate, height: isOn ? 0.495*kh : 48*sqrt(2)*rate)
        let targetCenterLine2 = isOn ? CGPoint(x: 0.4*kh, y: 0.48*kh) : CGPoint(x: kh/2, y: kh/2)
        
        let targetRotateAll: CGFloat = isOn ? -.pi : 0
        
        if !animated {
            self.center = CGPoint(x: isOn ? w-h/2 : h/2, y: center.y)
            self.backgroundColor = isOn ? backSwitch.knobOnBgColor : backSwitch.knobOffBgColor
            
            self.layer.shadowOpacity = isOn ? 0.4 : 0
            
            line1.bounds = targetBoundsLine1
            line1.center = targetCenterLine1
            
            line2.bounds = targetBoundsLine2
            line2.center = targetCenterLine2
            
            self.transform = CGAffineTransform(rotationAngle: targetRotateAll)
        } else {
            UIView.animate(withDuration: backSwitch.duration, animations: { [unowned self] in
                self.center = CGPoint(x: isOn ? self.backSwitch.bounds.width - self.backSwitch.bounds.height/2 : self.backSwitch.bounds.height/2, y: self.center.y)
                self.backgroundColor = isOn ? self.backSwitch.knobOnBgColor : self.backSwitch.knobOffBgColor
                }, completion:nil)
            
            let duration = self.backSwitch.duration
            let shadow = POPBasicAnimation(propertyNamed: kPOPLayerShadowOpacity)
            shadow?.toValue = isOn ? 0.4 : 0
            shadow?.duration = duration
            self.layer.pop_add(shadow, forKey: "shadow")
            
            let rotateAll = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
            rotateAll?.toValue = targetRotateAll
            rotateAll?.duration = duration
            self.layer.pop_add(rotateAll, forKey: "rotateAll")
            
            // line1
            let resize = POPBasicAnimation(propertyNamed: kPOPViewSize)
            resize?.toValue = targetBoundsLine1.size
            resize?.duration = duration
            line1.pop_add(resize, forKey: "resize")

            let translation = POPBasicAnimation(propertyNamed: kPOPViewCenter)
            translation?.toValue = targetCenterLine1
            translation?.duration = duration
            line1.pop_add(translation, forKey: "translation")

            // line2
            let resize2 = POPBasicAnimation(propertyNamed: kPOPViewSize)
            resize2?.toValue = targetBoundsLine2.size
            resize2?.duration = duration
            line2.pop_add(resize2, forKey: "resize")

            let translation2 = POPBasicAnimation(propertyNamed: kPOPViewCenter)
            translation2?.toValue = targetCenterLine2
            translation2?.duration = duration
            line2.pop_add(translation2, forKey: "translation")
        }
    }
    
    //MARK: ------------ Private ------------
    func generateLine(withRotationAngle angle: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 2
        view.transform = CGAffineTransform(rotationAngle: angle)
        addSubview(view)
        return view
    }
}
