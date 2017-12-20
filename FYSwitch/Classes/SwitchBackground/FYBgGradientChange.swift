//
//  FYBgGradientChange.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/19.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import ReactiveSwift

class FYBgGradientChange: CAGradientLayer, ISwitch {    // 渐变背景
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            locations = [0, 0.25, 0.5, 0.75, 1]
            startPoint = .zero
            endPoint = CGPoint(x: 1, y: 0)
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        self.frame = boundary//backSwitch.bounds
        self.cornerRadius = bounds.height/2
        
        toggle(to: backSwitch.on, animated: false)
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        // on/off状态切换时不做任何变化
        
        var targetColors: [CGColor]!
        if isOn {
            targetColors = [UIColor(red: 231/255.0, green: 156/255.0, blue: 49/255.0, alpha: 1).cgColor,
                            UIColor(red: 231/255.0, green: 140/255.0, blue: 49/255.0, alpha: 1).cgColor,
                            UIColor(red: 231/255.0, green: 123/255.0, blue: 49/255.0, alpha: 1).cgColor,
                            UIColor(red: 231/255.0, green: 107/255.0, blue: 49/255.0, alpha: 1).cgColor,
                            UIColor(red: 231/255.0, green: 99/255.0, blue: 49/255.0, alpha: 1).cgColor,
            ]
        } else {
            targetColors = [UIColor(red: 008/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1).cgColor,
                            UIColor(red: 008/255.0, green: 222/255.0, blue: 214/255.0, alpha: 1).cgColor,
                            UIColor(red: 008/255.0, green: 222/255.0, blue: 214/255.0, alpha: 1).cgColor,
                            UIColor(red: 008/255.0, green: 222/255.0, blue: 199/255.0, alpha: 1).cgColor,
                            UIColor(red: 024/255.0, green: 222/255.0, blue: 185/255.0, alpha: 1).cgColor,
            ]
        }
        
        if !animated {
            colors = targetColors
        }
        else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(backSwitch.duration)
            colors = targetColors
            CATransaction.commit()
        }
    }

}
