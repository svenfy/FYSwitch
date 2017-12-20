//
//  FYCapsuleKnob.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/20.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import pop

class FYCapsuleKnob: UIView, IKnob, POPAnimationDelegate {
    lazy var divideLayer: CALayer = {
        let divide = CALayer()
        divide.zPosition = 5
        divide.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(divide)
        return divide
    }()
    lazy var springLayer: CAShapeLayer = {
        let spring = CAShapeLayer()
        spring.zPosition = 4
        layer.addSublayer(spring)
        return spring
    }()
    lazy var springHelperView: UIView = {
        let helper = UIView(frame: .zero)
        addSubview(helper)
        return helper
    }()
    lazy var imageLayer: CALayer = {
        let image = CALayer()
        image.zPosition = 3
        layer.addSublayer(image)
        return image
    }()
    
    //MARK: ------------ IKnob ------------
    @objc dynamic weak var backSwitch: FYSwitch!
    
    func adjustPosition(withBoundary boundary: CGRect) {
        frame = backSwitch.bounds
        
        divideLayer.frame = CGRect(x: center.x-11/425.0*bounds.width, y: 0, width: 22/425.0*bounds.width, height: bounds.height)
        springLayer.frame = bounds
        
        imageLayer.bounds = CGRect(x: 0, y: 0, width: 86/425.0*bounds.width, height: 86/425.0*bounds.width)
        imageLayer.cornerRadius = imageLayer.bounds.height/2
        
        toggle(to: backSwitch.on, animated: false)
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        if !animated {
            imageLayer.position = isOn ? CGPoint(x: bounds.width - bounds.height/2, y: bounds.height/2) : CGPoint(x: bounds.height/2, y: bounds.height/2)
            imageLayer.backgroundColor = (isOn ? backSwitch.knobOnBgColor : backSwitch.knobOffBgColor)?.cgColor
            imageLayer.contents = fyswitch_image(named: isOn ? "delete" : "right")?.cgImage
        }
        else {
            let targetCenter = isOn ? CGPoint(x: center.x + imageLayer.bounds.width/2, y: center.y) : CGPoint(x: center.x - imageLayer.bounds.width/2, y: center.y)
            CATransaction.begin()
            CATransaction.setAnimationDuration(20/80.0*backSwitch.duration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
            imageLayer.position = targetCenter
            imageLayer.transform = CATransform3DMakeScale(7/8.6, 7/8.6, 1)
            CATransaction.commit()
            
            let shape = POPCustomAnimation(block: { (shape, anim) -> Bool in
                guard let anim = anim else { return false; }
                
                let time = anim.currentTime - anim.beginTime
                if time < 20/80.0*self.backSwitch.duration {
                    let xx = isOn ? self.imageLayer.presentation()!.frame.maxX : self.imageLayer.presentation()!.frame.minX
                    if isOn && xx > self.center.x || !isOn && xx < self.center.x {
                        self.updatePath(with: (xx - self.center.x)*2.2 + self.center.x)
                    }
                    return true
                }
                self.imageLayer.contents = fyswitch_image(named: isOn ? "delete" : "right")?.cgImage
                self.imageLayer.backgroundColor = (isOn ? self.backSwitch.knobOnBgColor : self.backSwitch.knobOffBgColor)?.cgColor
                return false
            })
            shape?.delegate = self
            shape?.setValue(isOn, forKey: "isOn")
            self.springLayer.pop_add(shape, forKey: "decay")
        }
    }
    
    func pop_animationDidStop(_ anim: POPAnimation!, finished: Bool) {
        if let isOn = anim.value(forKey: "isOn") as? Bool {
            let origin = (self.imageLayer.position.x - self.center.x)*2.2 + self.center.x
            let delta = (self.center.x - self.imageLayer.position.x)*2.2
            
            let (scaleOrigin, scaleTarget): (CGFloat, CGFloat) = (7/8.6, 1.1)
            let spring = POPCustomAnimation(block: { (shape, anim) -> Bool in
                guard let anim = anim else { return false; }
                
                let time = anim.currentTime - anim.beginTime
                if time < 10/80.0 * self.backSwitch.duration {
                    let scale = scaleOrigin + CGFloat(time/(10/80.0 * self.backSwitch.duration))*(scaleTarget-scaleOrigin)
                    self.imageLayer.transform = CATransform3DMakeScale(scale, scale, 1)
                } else if time <= 16/80.0 * self.backSwitch.duration {
                    let scale = scaleTarget + CGFloat((time/self.backSwitch.duration-10/80.0)/(6/80.0))*(1-scaleTarget)
                    self.imageLayer.transform = CATransform3DMakeScale(scale, scale, 1)
                } else {
                    self.imageLayer.transform = CATransform3DMakeScale(1, 1, 1)
                }
                if time < 0.75 * self.backSwitch.duration {
                    let targetValue = origin + Spring_1_100_2_2(time/(0.75 * self.backSwitch.duration))*delta
                    self.updatePath(with: targetValue)
                    return true
                }
                
                return false
            })
            springLayer.pop_add(spring, forKey: "spring")
            
            let target =  isOn ? bounds.width - bounds.height/2 : bounds.height/2
            CATransaction.begin()
            CATransaction.setAnimationDuration(10/80.0 * self.backSwitch.duration)
            imageLayer.position = CGPoint(x: target, y: center.y)
            CATransaction.commit()
        }
    }
    
    func updatePath(with controllPointX: CGFloat) {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: center.x, y: 0))
        path.addQuadCurve(to: CGPoint(x: center.x, y: bounds.height), controlPoint: CGPoint(x: controllPointX, y: bounds.height/2))
        path.close()
        
        springLayer.path = path.cgPath
        springLayer.fillColor = (controllPointX > center.x ? backSwitch.knobOnBgColor : backSwitch.knobOffBgColor)?.cgColor
    }
}
