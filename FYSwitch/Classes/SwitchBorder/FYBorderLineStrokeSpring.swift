//
//  FYBorderLineStrokeSpring.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/15.
//  Copyright © 2017年 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift
import pop

class FYBorderLineStrokeSpring: CAShapeLayer, ISwitch {
    lazy var onLayer: CAShapeLayer = {
        let on = CAShapeLayer()
        on.fillColor = UIColor.clear.cgColor
        addSublayer(on)
        return on
    }()
    
    //MARK: ---------- ISwitch ----------
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.borderOnColor)).producer.startWithValues { [unowned self] in
                self.onLayer.strokeColor = $0?.cgColor
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.borderOffColor)).producer.startWithValues { [unowned self] in
                self.strokeColor = $0?.cgColor
            }
            
            fillColor = UIColor.clear.cgColor
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        if let backSwitch = self.backSwitch {
            frame = backSwitch.bounds
            onLayer.frame = boundary
            
            configurateBorders()
        }
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        let start: (origin: CGFloat, target: CGFloat) = isOn ? (0.25, 0) : (0, 0.25)
        let end: (origin: CGFloat, target: CGFloat) = isOn ? (0.75, 0) : (0, 0.75)

        if !animated {
            onLayer.opacity = Float(isOn ? 0 : 1)
            onLayer.strokeStart = start.target
            onLayer.strokeEnd = end.target
        }
        else {
            // on/off状态切换时线性渐变
            let anim = POPCustomAnimation { [unowned self] (border, anim) -> Bool in
                if let border = border as? CAShapeLayer, let anim = anim {
                    let time = anim.currentTime - anim.beginTime
                    border.opacity = Float(isOn ? 1 - time/self.backSwitch.duration : time/self.backSwitch.duration)
                    if time < self.backSwitch.duration {
                        border.strokeStart = start.origin + (start.target - start.origin)*CGFloat(time/self.backSwitch.duration)
                        border.strokeEnd = end.origin + (end.target - end.origin)*CGFloat(time/self.backSwitch.duration)
                        return true
                    }
                }
                self.onLayer.opacity = Float(isOn ? 0 : 1)
                self.onLayer.strokeStart = start.target
                self.onLayer.strokeEnd = end.target
                return false
            }
            onLayer.pop_add(anim, forKey: nil)
        }
    }
    
    //MARK: ---------- ISwitch ----------
    func configurateBorders() {
        let (w, r) = (onLayer.bounds.width, onLayer.bounds.height/2)
        let (lc, rc) = (CGPoint(x: r, y: r), CGPoint(x: w-r, y: r))
        
        func generatePaht() -> UIBezierPath {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: w, y: r))
            path.addArc(withCenter: rc, radius: r, startAngle: 0, endAngle: -.pi/2, clockwise: false)
            path.addLine(to: CGPoint(x: r, y: 0))
            path.addArc(withCenter: lc, radius: r, startAngle: .pi*3/2, endAngle: .pi/2, clockwise: false)
            path.addLine(to: CGPoint(x: w-r, y: r*2))
            path.addArc(withCenter: rc, radius: r, startAngle: .pi/2, endAngle: -.pi/2, clockwise: false)
            path.addLine(to: CGPoint(x: r, y: 0))
            path.addArc(withCenter: lc, radius: r, startAngle: .pi*3/2, endAngle: .pi/2, clockwise: false)
            path.addLine(to: CGPoint(x: w-r, y: r*2))
            path.addArc(withCenter: rc, radius: r, startAngle: .pi/2, endAngle: 0, clockwise: false)
            return path
        }
        
        onLayer.path = generatePaht().cgPath
        
        if backSwitch.on {
            onLayer.strokeStart = 0
            onLayer.strokeEnd = onLayer.strokeStart
        } else {
            onLayer.strokeStart = 0.25
            onLayer.strokeEnd = onLayer.strokeStart + 0.5
        }
        
        onLayer.lineWidth = backSwitch.borderWidth
        onLayer.strokeColor = backSwitch.borderOnColor.cgColor
        
        path = UIBezierPath(roundedRect: onLayer.frame, cornerRadius: r).cgPath
        lineWidth = onLayer.lineWidth/2
        strokeColor = backSwitch.borderOffColor.cgColor
    }
}
