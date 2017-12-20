//
//  FYDayNightBg2.swift
//  FYSwitch
//
//  Created by FuYong on 12/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import pop

class FYDayNightBg2: FYBgLinearChange {
    override var relative: (startTime: Double, duration: Double) {
        get { return (0.0, 0.5) }
        set { }
    }
    
    /*
     * off -> on
     *  1. 星星被完全遮挡后，size设置为zero
     *  2. 背景在KnobExpanded完成时已经渐变完毕
     * on -> off 不被遮挡时，各自依次开启先大后小的动画
     */
    lazy var stars: [CALayer] = {
        let array = [CALayer(),CALayer(),CALayer(),CALayer(),CALayer(),CALayer(),CALayer()]
        array.forEach { star in
            star.backgroundColor = UIColor.white.cgColor
            insertSublayer(star, at: 0)
        }
        return array
    }()
    enum StarStatus {
        case prepare, ing, finished
    }
    lazy var starStatuses: [StarStatus] = {
        return Array<StarStatus>.init(repeating: .prepare, count: stars.count)
    }()
    
    var starProperties: [(CGFloat, CGFloat, CGFloat)] {
        get {
            // (x/w,y/h,r/h)
            return [(0.505, 0.235, 0.10),
                    (0.8, 0.205, 0.1),
                    (111/175, 0.395, 0.08),
                    (302/352, 0.47, 0.11),
                    (251/352, 0.605, 0.08),
                    (295/352, 0.735, 0.095),
                    (192/352, 0.8, 0.1),]
        }
    }
    
    override func toggle(to isOn: Bool, animated: Bool) {
        super.toggle(to: isOn, animated: animated)
        
        if !animated {
            for (index, star) in stars.enumerated() {
                if isOn {
                    star.bounds = .zero
                } else {
                    let r = (starProperties[index].2 - 0.02) * bounds.height / 2
                    star.bounds = CGRect(x: 0, y: 0, width: r*2, height: r*2)
                    star.cornerRadius = r
                }
            }
        }
    }
    
    override func adjustPosition(withBoundary boundary: CGRect) {
        super.adjustPosition(withBoundary: boundary)

        for (index, layer) in stars.enumerated() {
            layer.position = CGPoint(x: (starProperties[index].0 + 0.02) * boundary.width, y: starProperties[index].1 * boundary.height)
        }
        
        toggle(to: backSwitch.on, animated: false)
    }
    
    func restoreStatuses() {
        starStatuses = Array<StarStatus>.init(repeating: .prepare, count: stars.count)
    }
    
    func updatePrepareTo(status isOn: Bool) {
        func startHide(starAt index: Int, star: CALayer) {
            if starStatuses[index] == .prepare && (backSwitch.knob as! UIView).frame.intersects(convert(star.frame, to: backSwitch.layer)) {
                starStatuses[index] = .ing
                let anim = POPBasicAnimation(propertyNamed: kPOPLayerSize)
                anim?.toValue = CGSize.zero
                anim?.duration = 0.1
                star.pop_add(anim, forKey: "resize1")
            }
        }
        func startShow(starAt index: Int, star: CALayer) {
            let knob = backSwitch.knob as! UIView
            let path = UIBezierPath(roundedRect: knob.frame, cornerRadius: knob.frame.height/2)
            
            if starStatuses[index] == .prepare && knob.center.x < star.position.x && !path.contains(star.position) {
                starStatuses[index] = .ing
                
                let resize = POPCustomAnimation(block: { (star, anim) -> Bool in
                    guard let star = star as? CALayer, let anim = anim else { return false }
                        
                    let time = anim.currentTime - anim.beginTime;
                    guard time < 1 else { return false }
                    
                    let r = CGFloat(Spring_1_100_5_0(time*2))*(self.starProperties[index].2 - 0.02) * self.bounds.height/2
                    star.bounds = CGRect(x: 0, y: 0, width: r*2, height: r*2)
                    star.cornerRadius = r
                    return true
                })
                star.pop_add(resize, forKey: "resize2")
            }
        }
        
        for (index, star) in stars.enumerated() {
            if isOn {
                startHide(starAt: index, star: star)
            } else {
                startShow(starAt: index, star: star)
            }
        }
    }
}
