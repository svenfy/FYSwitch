//
//  FYDayNightKnob2.swift
//  FYSwitch
//
//  Created by FuYong on 12/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift
import pop

class FYDayNightKnob2: UIView, IKnob {
    let borderRate = 8.0/114

    lazy var background: CALayer = {
        let layer = CALayer()
        layer.zPosition = 2
        self.layer.addSublayer(layer)
        return layer
    }()
    let cloud: UIImageView = UIImageView(image: fyswitch_image(named: "cloud2"))
    lazy var planet: CALayer = {
        let layer = CALayer()
        layer.zPosition = 3
        self.layer.addSublayer(layer)
        return layer
    }()
    
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOnBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                if self.backSwitch.on { self.background.backgroundColor = color?.cgColor }
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOffBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                if !self.backSwitch.on { self.background.backgroundColor = color?.cgColor }
            }
            
            if cloud.superview == nil {
                backSwitch.addSubview(cloud)
            }
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        if let backSwitch = self.backSwitch {
            let x = backSwitch.on ? boundary.maxX - boundary.height : boundary.minX
            let newFrame = CGRect(x: x, y: boundary.minY, width: boundary.height, height: boundary.height)
            
            frame = newFrame
            background.frame = bounds
            background.cornerRadius = bounds.height/2
            planet.frame = bounds
            
            cloud.center = CGPoint(x: 0.5*backSwitch.bounds.width , y: 0.6*backSwitch.bounds.height)
        }
        toggle(to: backSwitch.on, animated: false)
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        let targetCenter = CGPoint(x: isOn ? self.backSwitch.bounds.width - self.backSwitch.bounds.height/2 : self.backSwitch.bounds.height/2, y: self.center.y)
        background.backgroundColor = (isOn ? backSwitch.knobOnBgColor : backSwitch.knobOffBgColor)?.cgColor
        planet.contents = fyswitch_image(named: backSwitch.on ? "sun" : "moon")?.cgImage
        self.superview?.bringSubview(toFront: isOn ? cloud : self)
        
        if !animated {
            self.center = targetCenter
            
            cloud.bounds = CGRect(origin: .zero, size: backSwitch.on ?  CGSize(width: 62/78*bounds.height, height: 42/78*bounds.height) : .zero)
            
            return
        }
        
        /* off -> on
         *  background => 先膨胀，位移，再收缩
         *  planet => 旋转，旋转，不动
         *  cloud => 中途开始收缩（Spring）
         *  stars => 被完全遮盖住后消失
         *
         * on -> off
         *  background => 先膨胀，位移，再收缩
         *  planet => 旋转，旋转，不动
         *  cloud => 置于底层，被background完全遮盖住后隐藏
         *  stars => 显露出来后开始SpringSize动画
         */
        
        let anim = POPCustomAnimation { [unowned self] (_, animation) -> Bool in
            guard let animation = animation else { return false; }
            
            let time = animation.currentTime - animation.beginTime;
            let expand = 0.25, translate = expand + 1/6, shrink = translate + 0.25
            
            let finishedRate = time/self.backSwitch.duration
            switch finishedRate {
            case 0..<expand:
                self.expandPrepareTo(status: isOn, finished: CGFloat(finishedRate/expand))
            case expand..<translate:
                self.translatePrepareTo(status: isOn, finished: CGFloat(finishedRate-expand)*6)
                self.cloudStart(animateToStatus: isOn)
            case translate..<shrink+0.02:
                self.shrinkPrepareTo(status: isOn, finished: CGFloat(finishedRate-translate)/0.25)
            case shrink...1:
                break
            default:
                (self.backSwitch.bgLayer as? FYDayNightBg2)?.restoreStatuses()
                self.cloud.setValue(false, forKey: "animating")
                return false
            }
            
            return true;
        }
        self.pop_add(anim, forKey: nil)
    }
    
    let expandRate = CGFloat(114.0/76)
    func expandPrepareTo(status isOn: Bool, finished percent: CGFloat) {
        let h = bounds.height
        let targetW = h + h * (expandRate-1) * percent
        
        self.frame = CGRect(x: isOn ? backSwitch.knobMargin : backSwitch.bounds.width - backSwitch.knobMargin - targetW, y: backSwitch.knobMargin, width: targetW, height: h)
        background.frame = bounds
        planet.frame = CGRect(origin: CGPoint(x: isOn ? bounds.width - h : 0, y: 0), size: planet.bounds.size)
    }
    
    func translatePrepareTo(status isOn: Bool, finished percent: CGFloat) {
        let (w, h) = (background.bounds.height*expandRate, background.bounds.height)
        let targetX = backSwitch.knobMargin + (backSwitch.bounds.width - backSwitch.knobMargin*2 - w)*(isOn ? percent : 1-percent)
        
        frame = CGRect(x: targetX, y: backSwitch.knobMargin, width: w, height: h)
        (backSwitch.bgLayer as? FYDayNightBg2)?.updatePrepareTo(status: isOn)
    }
    
    func cloudStart(animateToStatus isOn: Bool) {
        if !(cloud.value(forKey: "animating") as? Bool ?? false) {
            cloud.setValue(true, forKey: "animating")
            if isOn {   // size Spring
                let resize = POPSpringAnimation(propertyNamed: kPOPViewSize)
                resize?.toValue = CGSize(width: 62/78*bounds.height, height: 42/78*bounds.height)
                resize?.springSpeed = 1.5
                resize?.dynamicsFriction = 6
                cloud.pop_add(resize, forKey: "resize")
            }
            else {      // size shrink
                UIView.animate(withDuration: 0.2, animations: {
                    self.cloud.bounds = CGRect(origin: .zero, size: .zero)
                })
            }
        }
    }
    
    func shrinkPrepareTo(status isOn: Bool, finished percent: CGFloat) {
        let h = background.bounds.height
        let targetW = h + h * (expandRate-1) * max(0, (1-percent))
        
        frame = CGRect(x: isOn ? backSwitch.bounds.width - backSwitch.knobMargin - targetW : backSwitch.knobMargin, y: backSwitch.knobMargin, width: targetW, height: h)
        background.frame = bounds
        planet.frame = CGRect(origin: CGPoint(x: isOn ? bounds.width - h : 0, y: 0), size: planet.bounds.size)

        if !isOn {
            (backSwitch.bgLayer as? FYDayNightBg2)?.updatePrepareTo(status: isOn)
        }
    }
}
