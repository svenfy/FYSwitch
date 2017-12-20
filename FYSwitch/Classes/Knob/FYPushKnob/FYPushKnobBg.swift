//
//  FYPushKnobBg.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/19.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit

class FYPushKnobBg: FYBgLinearChange {
    override func adjustPosition(withBoundary boundary: CGRect) {
        self.frame = CGRect(origin: .zero, size: boundary.size)
        let path = UIBezierPath(roundedRect: boundary, cornerRadius: 5)
        self.path = path.cgPath
    }
}
