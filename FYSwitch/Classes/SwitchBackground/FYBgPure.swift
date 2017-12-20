//
//  FYBgPure.swift
//  FYSwitch
//
//  Created by FuYong on 11/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class FYBgPure: CAShapeLayer, ISwitch {    // 纯色背景，以 offBgColor 为准
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.offBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                self.fillColor = color?.cgColor
            }
        }
    }
    
    func adjustPosition(withBoundary frame: CGRect) {
        self.path = UIBezierPath(roundedRect: frame, cornerRadius: frame.height/2).cgPath
    }

    func toggle(to isOn: Bool, animated: Bool) {
        // on/off状态切换时不做任何变化
    }
}
