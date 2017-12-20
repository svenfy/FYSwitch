//
//  FYBgPointScale.swift
//  FYSwitch
//
//  Created by FuYong on 11/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift
import pop

class FYBgPointScale: CAShapeLayer, ISwitch {
    var scaleAnchor: (CGFloat, CGFloat) = (0.8, 0.5)    // 收缩/扩张的锚点，范围(0~1, 0~1)，默认为中心点
    
    lazy var onBgLayer: CALayer = {
        let layer = CALayer()
        addSublayer(layer)
        return layer
    }()
    fileprivate var expandedRadius: CGFloat {
        get {
            return max(scaleAnchor.0, 1-scaleAnchor.0)*bounds.width*2
        }
    }

    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            didSetBackSwitch(backSwitch)
        }
    }
    
    func didSetBackSwitch(_ backSwitch: FYSwitch) -> Void {
        Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.onBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
            self.onBgLayer.backgroundColor = color?.cgColor
        }
        Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.offBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
            self.fillColor = color?.cgColor
        }
        Property<Bool>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.on)).producer.startWithValues { [unowned self] (isOn) in
            if isOn {
                self.onBgLayer.bounds = CGRect(x: 0, y: 0, width: self.expandedRadius*2, height: self.expandedRadius*2)
                self.onBgLayer.cornerRadius = self.expandedRadius
            } else {
                self.onBgLayer.bounds = .zero
                self.onBgLayer.cornerRadius = 0
            }
        }
        
        self.masksToBounds = true
    }

    func adjustPosition(withBoundary boundary: CGRect) {
        if frame.width != boundary.width || frame.height != boundary.height {
            self.frame = boundary
            self.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2).cgPath
            self.cornerRadius = boundary.height / 2

            self.onBgLayer.position = CGPoint(x: scaleAnchor.0 * bounds.width, y: scaleAnchor.1 * bounds.height)
        }
    }

    func toggle(to isOn: Bool, animated: Bool) {
        let w = isOn ? max(scaleAnchor.0, 1-scaleAnchor.0)*bounds.width*2 : 0
        let targetBounds = CGRect(x: 0, y: 0, width: w, height: w)
        let targetCornerRadius = w/2
        
        if !animated {
            onBgLayer.bounds = targetBounds
            onBgLayer.cornerRadius = targetCornerRadius
        }
        else {
            let resize = POPBasicAnimation(propertyNamed: kPOPLayerSize)!
            resize.toValue = targetBounds.size
            resize.duration = backSwitch.duration
            onBgLayer.pop_add(resize, forKey: "resize")
            
            let radius = POPBasicAnimation(propertyNamed: kPOPLayerCornerRadius)!
            radius.toValue = targetCornerRadius
            radius.duration = backSwitch.duration
            onBgLayer.pop_add(radius, forKey: "radius")
        }
        
    }
}
