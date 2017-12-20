//
//  FYDayNightKnob3.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/15.
//  Copyright © 2017年 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift
import pop

class FYDayNightKnob3: UIView, IKnob {
    lazy var planet: CAShapeLayer! = {
        let planet = CAShapeLayer()
        self.layer.addSublayer(planet)
        return planet
    }()
    //MARK: ---------- ISwitch ----------
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOnBgColor)).producer.startWithValues { [unowned self] in
                self.planet.fillColor = $0?.cgColor
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOffBgColor)).producer.startWithValues { [unowned self] in
                self.planet.fillColor = $0?.cgColor
            }
        }
    }

    
    func adjustPosition(withBoundary boundary: CGRect) {
        if let backSwitch = self.backSwitch {
            let newFrame = CGRect(origin: CGPoint(x: backSwitch.on ? boundary.maxX - boundary.height : boundary.minX, y: boundary.minY),
                                  size: CGSize(width: boundary.height, height: boundary.height))
            frame = newFrame
            
            planet.frame = bounds
        }
        toggle(to: backSwitch.on, animated: false)
    }

    func toggle(to isOn: Bool, animated: Bool) {
        let targetCenter = CGPoint(x: isOn ? self.backSwitch.bounds.width - self.backSwitch.bounds.height/2 : self.backSwitch.bounds.height/2, y: self.center.y)
        
        if !animated {
            if isOn {
                // 一个控制点
                updatePath(percent: 1)
                planet.fillColor = backSwitch.knobOnBgColor.cgColor
            } else {
                planet.path = UIBezierPath(ovalIn: planet.bounds).cgPath
                planet.fillColor = backSwitch.knobOffBgColor?.cgColor
            }
            self.center = targetCenter
            
            self.backSwitch.superview?.backgroundColor = isOn ? self.backSwitch.onBgColor : self.backSwitch.offBgColor
            self.planet.fillColor = (isOn ? self.backSwitch.knobOnBgColor : self.backSwitch.knobOffBgColor)?.cgColor
            
            return
        }
        
        UIView.animate(withDuration: self.backSwitch.duration) { [unowned self] in
            self.backSwitch.superview?.backgroundColor = isOn ? self.backSwitch.onBgColor : self.backSwitch.offBgColor
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(backSwitch.duration)
        self.planet.fillColor = (isOn ? self.backSwitch.knobOnBgColor : self.backSwitch.knobOffBgColor)?.cgColor
        CATransaction.commit()
        
        // on/off状态切换时线性渐变
        let sizeRate: (CGFloat, CGFloat) = (0.6, 1.2)
        let anim = POPCustomAnimation { [unowned self] (planet, anim) -> Bool in
            if let planet = planet as? CAShapeLayer, let anim = anim {
                let time = anim.currentTime - anim.beginTime
                let rate = CGFloat(time/self.backSwitch.duration)
                
                let (w, h) = (self.backSwitch.bounds.width, self.backSwitch.bounds.height)
                let x = h/2 + (isOn ? min(rate/0.9,1) : 1 - min(rate/0.9,1))*(w-h)
                self.center = CGPoint(x: x, y: h/2)

                if isOn {
                    var newWidth: CGFloat!
                    switch rate {
                    case 0..<0.3:
                        newWidth = (1 + rate/0.3 * -0.4) * self.bounds.width
                    case 0.3..<0.9:
                        let finishedRate: CGFloat = (rate-0.3)/0.6*0.5
                        newWidth = (sizeRate.1 - 0.5 + finishedRate) * self.bounds.width
                    case 0.9...1:
                        let finishedRate: CGFloat = (rate-0.9)/0.1 * (1-sizeRate.1)
                        newWidth = (sizeRate.1 + finishedRate) * self.bounds.width
                    default:
                        return false
                    }
                    planet.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newWidth)
                    self.updatePath(percent: rate < 0.3 ? rate/0.3 : 1)
                } else {
                    var newWidth: CGFloat!
                    var percent: CGFloat = 1
                    switch rate {
                    case 0..<0.5:
                        newWidth = (1 + rate/0.5 * -0.4) * self.bounds.width
                    case 0.5..<0.9:
                        let finishedRate: CGFloat = (rate-0.5)/0.4 * 0.5
                        newWidth = (sizeRate.1 - 0.5 + finishedRate) * self.bounds.width
                        percent = max(0, 1 - (rate - 0.5)/0.3)
                    case 0.9...1:
                        let finishedRate: CGFloat = (rate-0.9)/0.1 * (1-sizeRate.1)
                        newWidth = (sizeRate.1 + finishedRate) * self.bounds.width
                        percent = 0
                    default:
                        return false
                    }
                    planet.frame = CGRect(x: (self.bounds.height - newWidth)/2, y: (self.bounds.height - newWidth)/2, width: newWidth, height: newWidth)
                    self.updatePath(percent: percent)
                }
            }
            
            return true
        }
        planet.pop_add(anim, forKey: nil)
    }
    
    let staticPointRate: CGFloat = 0.38
    func updatePath(percent: CGFloat) {
        if percent < 0.01 {
            planet.path = UIBezierPath(ovalIn: planet.bounds).cgPath
        } else {
            let path = UIBezierPath()
            let r = planet.bounds.height/2
            let y = sqrt(pow(r, 2) - pow((0.5 - staticPointRate)*r, 2))

            path.addArc(withCenter: CGPoint(x: r, y: r), radius: r, startAngle: -.pi/2 - acos(y/r), endAngle: .pi/2 + acos(y/r), clockwise: true)
            
            let controllPoint1 = CGPoint(x: (-0.125 + 0.865*percent)*2*r, y: (0.16 + 0.07*percent)*2*r)
            let controllPoint2 = CGPoint(x: controllPoint1.x, y: 2*r - controllPoint1.y)
            path.addCurve(to: CGPoint(x: path.currentPoint.x, y: 2*r - path.currentPoint.y), controlPoint1: controllPoint2, controlPoint2: controllPoint1)
            
            planet.path = path.cgPath
        }
        
    }
}
