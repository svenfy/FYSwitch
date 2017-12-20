//
//  FYImageTextSwitch.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/17.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit

class FYImageTextSwitch: FYSwitch {

    //MARK: ------------ Knob Text ------------
    @objc @IBInspectable dynamic var knobOnText: String?
    @objc @IBInspectable dynamic var knobOffText: String?
    
    //MARK: ------------ Knob Image ------------
    @objc @IBInspectable dynamic var knobOnImage: UIImage?
    @objc @IBInspectable dynamic var knobOffImage: UIImage?
}
