//
//  FYBorderLinearChange.swift
//  FYSwitch
//
//  Created by FuYong on 11/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift
import pop

class FYBorderLinearChange: CAShapeLayer, ISwitch {  // 纯色边框
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.borderOnColor)).signal.observeValues { [unowned self] in
                if self.backSwitch.on { self.strokeColor = $0?.cgColor }
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.borderOffColor)).signal.observeValues { [unowned self] in
                if !self.backSwitch.on { self.strokeColor = $0?.cgColor }
            }
            
            self.fillColor = UIColor.clear.cgColor
        }
    }
    
    func adjustPosition(withBoundary frame: CGRect) {
        self.path = UIBezierPath(roundedRect: frame, cornerRadius: frame.height/2).cgPath
        self.lineWidth = backSwitch.borderWidth
        if let backSwitch = self.backSwitch {
            self.frame = self.backSwitch.bounds
            self.strokeColor = (backSwitch.on ? backSwitch.borderOnColor : backSwitch.borderOffColor)?.cgColor
        }
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        if !animated {
            self.strokeColor = (backSwitch.on ? backSwitch.borderOnColor : backSwitch.borderOffColor)?.cgColor
        } else {
            // on/off状态切换时线性渐变
            let color = POPBasicAnimation(propertyNamed: kPOPShapeLayerStrokeColor)!
            color.toValue = (backSwitch.on ? backSwitch.borderOnColor : backSwitch.borderOffColor)?.cgColor
            color.duration = backSwitch.duration
            pop_add(color, forKey: nil)
        }
    }
}
