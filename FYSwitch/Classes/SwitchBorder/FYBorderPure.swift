//
//  FYBorderPure.swift
//  FYSwitch
//
//  Created by FuYong on 11/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift

class FYBorderPure: CAShapeLayer, ISwitch {    // 纯色边框
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.borderOffColor)).signal.observeValues { [unowned self] in
                self.strokeColor = $0?.cgColor
            }
            
            self.fillColor = UIColor.clear.cgColor
        }
    }
    
    func adjustPosition(withBoundary frame: CGRect) {
        self.path = UIBezierPath(roundedRect: frame, cornerRadius: frame.height/2).cgPath
        if let backSwitch = self.backSwitch {
            self.lineWidth = backSwitch.borderWidth
            self.strokeColor = backSwitch.borderOffColor?.cgColor
        }
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        // on/off状态切换时不做任何动画
    }
}
