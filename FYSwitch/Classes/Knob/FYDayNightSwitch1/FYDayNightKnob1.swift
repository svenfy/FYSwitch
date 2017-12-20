//
//  FYDayNightKnob1.swift
//  FYSwitch
//
//  Created by FuYong on 11/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift

class FYDayNightKnob1: UIView, IKnob {
    lazy var sunLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.init(red: 255/255, green: 230/255, blue: 181/255, alpha: 1).cgColor
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    lazy var cloud: CALayer = {
        let layer = CALayer()
        layer.contents = fyswitch_image(named: "cloud1")?.cgImage
        self.layer.addSublayer(layer)
        return layer
    }()
    lazy var caters: [CALayer] = {
        let array = [CALayer(),CALayer(),CALayer(),]
        array.forEach { layer in
            layer.backgroundColor = UIColor.init(red: 230/255, green: 206/255, blue: 165/255, alpha: 1).cgColor
            self.layer.insertSublayer(layer, above: sunLayer)
        }
        return array
    }()
    
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOnBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                if self.backSwitch.on { self.backgroundColor = color }
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOffBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                if !self.backSwitch.on { self.backgroundColor = color }
            }
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        if let backSwitch = self.backSwitch {
            let newFrame = CGRect(origin: CGPoint(x: backSwitch.on ? boundary.maxX - boundary.height : boundary.minX, y: boundary.minY),
                                  size: CGSize(width: boundary.height, height: boundary.height))
            self.layer.cornerRadius = newFrame.height/2
            self.frame = newFrame
            
            self.sunLayer.frame = bounds.insetBy(dx: 2, dy: 2)
            self.sunLayer.cornerRadius = sunLayer.bounds.height/2
            
            let caterProperties: [(CGFloat, CGFloat, CGFloat)]
                = [(0.185, 0.51, 0.05),
                   (0.3, 0.36, 0.10),
                   (0.305, 0.65, 0.07),
                   ]
            for (index, layer) in caters.enumerated() {
                let r = caterProperties[index].2 * boundary.height
                layer.frame = CGRect(x: 0, y: 0, width: r*2, height: r*2)
                layer.position = CGPoint(x: caterProperties[index].0 * boundary.width, y: caterProperties[index].1 * boundary.height)
                layer.cornerRadius = r
            }
            
            self.cloud.frame = CGRect(origin: caters[0].position, size: .zero)
            
            toggle(to: backSwitch.on, animated: false)
        }
    }

    func toggle(to isOn: Bool, animated: Bool) {
        let targetCenter = CGPoint(x: isOn ? self.backSwitch.bounds.width - self.backSwitch.bounds.height/2 : self.backSwitch.bounds.height/2, y: self.center.y)
        if !animated {
            self.center = targetCenter
            caters.forEach { $0.opacity = isOn ? 0 : 1 }
            let rate = bounds.width/40
            cloud.frame = isOn ? CGRect(x: -16.5*rate, y: 10*rate, width: 31*rate, height: 21*rate) : CGRect(origin: caters[0].position, size: .zero)
        }
        else {
            UIView.animate(withDuration: backSwitch.duration, animations: { [unowned self] in
                self.center = targetCenter
                }, completion:nil)
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(self.backSwitch.duration)
            caters.forEach { $0.opacity = isOn ? 0 : 1 }
            let rate = bounds.width/40
            cloud.frame = isOn ? CGRect(x: -18*rate, y: 10*rate, width: 31*rate, height: 21*rate) : CGRect(origin: caters[0].position, size: .zero)
            CATransaction.commit()
        }
    }
}
