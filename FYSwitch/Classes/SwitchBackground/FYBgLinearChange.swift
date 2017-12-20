//
//  FYBgLinearChange.swift
//  FYSwitch
//
//  Created by FuYong on 11/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift

class FYBgLinearChange: CAShapeLayer, ISwitch {
    var relative: (startTime: Double, duration: Double) = (0, 1)  // 相对于backSwitch.duration
    
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.onBgColor)).producer.startWithValues { [unowned self] (color) in
                if !self.backSwitch.on { self.fillColor = color?.cgColor }
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.offBgColor)).producer.startWithValues { [unowned self] (color) in
                if !self.backSwitch.on { self.fillColor = color?.cgColor }
            }
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        self.frame = CGRect(origin: .zero, size: boundary.size)
        let path = UIBezierPath(roundedRect: boundary, cornerRadius: boundary.height/2)
        self.path = path.cgPath
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        if !animated {
            self.fillColor = (backSwitch.on ? backSwitch.onBgColor : backSwitch.offBgColor)?.cgColor
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + relative.startTime * backSwitch.duration) { [weak self] in
                if let strongSelf = self {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(strongSelf.relative.duration * strongSelf.backSwitch.duration)
                    strongSelf.fillColor = (isOn ? strongSelf.backSwitch.onBgColor : strongSelf.backSwitch.offBgColor)?.cgColor
                    CATransaction.commit()
                }
            }
        }
    }
}
