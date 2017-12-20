//
//  FYUtils.swift
//  FYSwitch
//
//  Created by FuYong on 13/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit

func Spring_1_100_5_0(_ ot: Double) -> Double { // 弹簧函数：命名规则为mass_stiffness_damping_initialVelocity，可用wolframalpha求解
    let t = ot//*2.85497460988;
    let c1 = pow(M_E, -5*t/2)
    let c2 = 5*sqrt(15)*t/2
    return 1 - c1*cos(c2) - (c1*sin(c2))/sqrt(15);
}

// 将 f(0) = 0; f'(0) = 10; f''(t) = (-100(f(t) - 1) - 2f'(t))/2 输入http://www.wolframalpha.com，得到弹簧公式如下
func Spring_1_100_2_2(_ ot: Double) -> CGFloat {
    let t = CGFloat(ot*3.2)
    let c1 = pow(CGFloat(M_E), -t/2)
    let c2 = t*sqrt(199)/2
    return 19*c1*sin(c2)/sqrt(199) - c1*cos(c2) + 1
}

func fyswitch_image(named: String) -> UIImage? {
    return UIImage.init(named: named, in: Bundle.init(for: FYSwitch.self), compatibleWith: nil)
}
