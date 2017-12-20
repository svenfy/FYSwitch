//
//  FYDayNightBg1.swift
//  FYSwitch
//
//  Created by FuYong on 11/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift

class FYDayNightBg1: FYBgPointScale {
    override var scaleAnchor: (CGFloat, CGFloat) {
        get {
            return (0.61, 0.5)
        }
        set { }
    }
    lazy var stars: [CALayer] = {
        let array = [CALayer(),CALayer(),CALayer(),CALayer(),CALayer(),CALayer(),]
        array.forEach { insertSublayer($0, at: 0) }
        return array
    }()
    
    override func didSetBackSwitch(_ backSwitch: FYSwitch) {
        Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.onBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
            self.onBgLayer.backgroundColor = color?.cgColor
            self.stars.forEach { $0.backgroundColor = color?.cgColor }
        }
        Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.offBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
            self.fillColor = color?.cgColor
        }
        
        self.masksToBounds = true
    }
    
    override func adjustPosition(withBoundary boundary: CGRect) {
        super.adjustPosition(withBoundary: boundary)
        
        let starProperties: [(CGFloat, CGFloat, CGFloat)]
            = [(0.535, 0.23, 0.03),
               (scaleAnchor.0, scaleAnchor.1, 0.04),
               (0.79, 0.32, 0.02),
               (0.53, 0.72, 0.01),
               (0.71, 0.78, 0.02),
               (0.835, 0.57, 0.01)]
        
        for (index, layer) in stars.enumerated() {
            let r = starProperties[index].2 * boundary.height
            layer.frame = CGRect(x: 0, y: 0, width: r*2, height: r*2)
            layer.position = CGPoint(x: starProperties[index].0 * boundary.width, y: starProperties[index].1 * boundary.height)
            layer.cornerRadius = r
        }
    }
}
