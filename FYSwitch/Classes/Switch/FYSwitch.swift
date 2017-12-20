//
//  FYSwitch.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/16.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

@objc protocol ISwitch: NSObjectProtocol {
    weak var backSwitch: FYSwitch! { get set }
    
    @objc func adjustPosition(withBoundary boundary: CGRect)    // 只调整位置，包括center/position、CornerRadius、path等
    @objc func toggle(to isOn: Bool, animated: Bool) -> Void
}

@objc protocol IKnob: ISwitch {
}

@objc protocol IExpandedKnob: IKnob {
    var expanded: Bool { get set }
}

@IBDesignable
class FYSwitch: UIView {
    fileprivate var animated: Bool = false
    @objc @IBInspectable dynamic var on: Bool = false {
        didSet {
            if oldValue != on {
                self.knob?.toggle(to: on, animated: animated)
                (self.bgLayer as? ISwitch)?.toggle(to: on, animated: animated)
                (self.borderLayer as? ISwitch)?.toggle(to: on, animated: animated)
                animated = false
            }
        }
    }
    @IBInspectable var duration: Double = 0.8
    
    //MARK: ------------ Switch Border ------------
    @IBInspectable fileprivate var borderIdentifier: String? {
        didSet {
            if let border = borderIdentifier {
                if let border = borderLayer {
                    border.removeFromSuperlayer()
                }
                
                borderLayer = generateInstance(ofClass: border) as? CALayer
                bgBorderView.layer.addSublayer(borderLayer!)
                
                adjustBorderLayer()
            }
        }
    }
    @objc @IBInspectable dynamic var borderMargin: CGFloat = 0    // border“外”边框到Switch边界的距离
    @objc @IBInspectable dynamic var borderWidth: CGFloat = 0
    @objc @IBInspectable dynamic var borderOnColor: UIColor!
    @objc @IBInspectable dynamic var borderOffColor: UIColor!
    
    //MARK: ------------ Switch Background ------------
    @IBInspectable fileprivate var bgIdentifier: String! {
        didSet {
            if let bg = bgLayer {
                bg.removeFromSuperlayer()
            }

            if let bgLayer = generateInstance(ofClass: bgIdentifier) as? CALayer {
                self.bgLayer = bgLayer
                bgBorderView.layer.insertSublayer(bgLayer, at: 0)
                adjustBgLayer()
            }
        }
    }

    @objc @IBInspectable dynamic var onBgColor: UIColor!
    @objc @IBInspectable dynamic var offBgColor: UIColor!
    
    //MARK: ------------ Knob Shadow ------------
    @IBInspectable fileprivate var knobIdentifier: String! {
        didSet {
            knob = generateInstance(ofClass: knobIdentifier) as! IKnob
            
            if let knob = self.knob as? UIView {
                addSubview(knob)
            }
            adjustKnob()
        }
    }
    @IBInspectable dynamic var knobMargin: CGFloat = 0  // knob外边框和Switch的边距
    @objc @IBInspectable dynamic var knobOnBgColor: UIColor!
    @objc @IBInspectable dynamic var knobOffBgColor: UIColor!
    
    //MARK: ------------ Backed CALayers ------------
    lazy var bgBorderView: UIView = {
        // 直接将bgLayer放置在self.layer上会遮挡Knob
        let view = UIView(frame: bounds)
        insertSubview(view, at: 0)
        return view
    }()
    var bgLayer: CALayer?
    var borderLayer: CALayer?
    var knob: IKnob!                // 可能是CALayer
    
    //MARK: ------------ Initialization ------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //MARK: ---------- Touch Events ----------
    
    func proccess(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let x = touches.first?.location(in: self).x else { return }
        
        if !moving && self.on != (x >= bounds.width / 2) {
            animated(to: x >= bounds.width / 2)
        } else if x >= bounds.width / 2 && !self.on {
            animated(to: true)
        } else if x < bounds.width / 2 && self.on {
            animated(to: false)
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let k = self.knob as? IExpandedKnob { k.expanded = true }
    }
    
    private var moving: Bool = false
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = true
        proccess(touches, withEvent: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.proccess(touches, withEvent: event)
        if let k = self.knob as? IExpandedKnob { k.expanded = false }
        moving = false
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches , with: event)
    }
    
    //MARK: ---------- Private Helper ----------
    func commonInit() {
        let switchBounds = Property<CGRect>.init(object: self, keyPath: #keyPath(bounds)).producer
        let bm = Property<CGFloat>.init(object: self, keyPath: #keyPath(borderMargin)).producer
        let bw = Property<CGFloat>.init(object: self, keyPath: #keyPath(borderWidth)).producer
        switchBounds.startWithValues { [unowned self] (bounds) in
            self.bgBorderView.frame = bounds
        }
        
        SignalProducer<CGRect, NoError>.combineLatest(switchBounds, bm, bw).startWithValues { [unowned self] _ in
            self.adjustBgLayer()
            self.adjustBorderLayer()
        }
        
        let km = DynamicProperty<CGFloat>.init(object: self, keyPath: #keyPath(knobMargin)).producer
        SignalProducer<CGRect, NoError>.combineLatest(switchBounds, km).startWithValues { [unowned self] _ in
            self.adjustKnob()
        }
    }
    
    func generateInstance(ofClass className: String) -> NSObject? {
        /*
         1、NSString.self()// 或者NSString.self.init()
         2、let myClass = MyClass.Type.init()
         3、let myClass = MyClass.self.init()
         4、let type = NSClassFromString("MyClass") as! MyClass.Type然后通过type.init()来创建对象
         */
        let name = className.contains(".") ? className : "FYSwitch.\(className)"
        let type = NSClassFromString(name) as! NSObject.Type
        let obj = type.init()

        if let obj = obj as? ISwitch {
            obj.backSwitch = self
        }

        return obj
    }

    func adjustBgLayer() {
        if let bg = self.bgLayer as? ISwitch {
            bg.adjustPosition(withBoundary: bounds.insetBy(dx: borderMargin+borderWidth/2, dy: borderMargin+borderWidth/2))
        }
    }
    
    func adjustBorderLayer() {
        if let border = self.borderLayer as? ISwitch {
            border.adjustPosition(withBoundary: bounds.insetBy(dx: borderMargin+borderWidth/2, dy: borderMargin+borderWidth/2))
        }
    }
    
    func adjustKnob() {
        if let knob = self.knob {
            knob.adjustPosition(withBoundary: bounds.insetBy(dx: knobMargin, dy: knobMargin))
        }
    }
    
    func animated(to isOn: Bool) {
        animated = true
        on = isOn
    }
}
