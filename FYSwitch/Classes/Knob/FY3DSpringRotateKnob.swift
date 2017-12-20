//
//  FY3DSpringRotateKnob.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/18.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import ReactiveSwift
import pop
import AHEasing

class FY3DSpringRotateKnob: UIView , IKnob {
    // 从底往上
    lazy var backgroundLayer: CALayer = {
        var layer = CALayer()
        layer.contents = fyswitch_image(named: "face_back")?.cgImage
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    lazy var borderLayer: CAShapeLayer = {
        var layer = CAShapeLayer()
        layer.lineWidth = 3
        layer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(layer)
        return layer
    }()
    lazy var maskLayer: CAShapeLayer = {
        var layer = CAShapeLayer()
        layer.fillColor = UIColor.red.cgColor
        self.borderLayer.mask = layer
        borderLayer.mask = layer
        return layer
    }()
    var faceLayer: CATransformLayer!
    
    
    //MARK: ------------ IKnob ------------
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOnBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                if self.backSwitch.on { self.borderLayer.strokeColor = color?.cgColor }
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.knobOffBgColor)).producer.startWithValues { [unowned self] (color) -> Void in
                if !self.backSwitch.on { self.borderLayer.strokeColor = color?.cgColor }
            }
        }
    }
    
    func adjustPosition(withBoundary frame: CGRect) {
        if let backSwitch = self.backSwitch {
            let newFrame = CGRect(origin: CGPoint(x: backSwitch.on ? frame.maxX - frame.height : frame.minX, y: frame.minY),
                                  size: CGSize(width: frame.height, height: frame.height))
            self.frame = newFrame
            backgroundLayer.frame = bounds.insetBy(dx: borderLayer.lineWidth, dy: borderLayer.lineWidth)
            
            borderLayer.frame = self.bounds
            borderLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: borderLayer.lineWidth/2, dy: borderLayer.lineWidth/2)).cgPath
            
            maskLayer.frame = self.bounds
            let path = UIBezierPath()
            let r = newFrame.height/2, p = borderLayer.lineWidth * 2

            path.move(to: CGPoint(x: r + sqrt(pow(r,2)-pow(r-p,2)), y: p))
            path.addArc(withCenter: CGPoint(x: r, y: r), radius: r, startAngle: acos(1-p/r) - .pi/2, endAngle: .pi/2 - acos(1-p/r), clockwise: true)
            path.addLine(to: CGPoint(x: sqrt(pow(r,2)-pow(r-p,2)), y: r*2-p))
            path.addArc(withCenter: CGPoint(x: r, y: r), radius: r, startAngle: .pi/2+acos(1-p/r), endAngle: .pi*3/2-acos(1-p/r), clockwise: true)
            path.close()
            
            maskLayer.position = CGPoint(x: r + (backSwitch.on ? -p*3 : p*3), y: r)
            maskLayer.path = path.cgPath
            
            configurateFaceLayer()
            toggle(to: backSwitch.on, animated: false)
        }
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        let (fromValue, toValue): (Double, Double) = isOn ? (0, .pi) : (.pi, 0)
        let w = self.backSwitch.bounds.width, h = self.backSwitch.bounds.height
        
        if !animated {
            self.center = CGPoint(x: isOn ? w-h/2 : h/2, y: self.center.y)
            
            let color = isOn ? self.backSwitch.borderOnColor : self.backSwitch.borderOffColor
            self.borderLayer.strokeColor = color?.cgColor
            (self.backSwitch.borderLayer as? CAShapeLayer)?.strokeColor = color?.cgColor
            
            let bgColor = (isOn ? self.backSwitch.onBgColor : self.backSwitch.offBgColor)?.cgColor
            (self.backSwitch.bgLayer as? CAShapeLayer)?.fillColor = bgColor
            
            maskLayer.position = CGPoint(x: h/2 + (isOn ? -1 : 1)*borderLayer.lineWidth*6, y: h/2)
            faceLayer.transform = CATransform3DMakeRotation(CGFloat(toValue), 0, 1, 0)
        }
        else {
            UIView.animate(withDuration: backSwitch.duration, animations: { [unowned self] in
                self.center = CGPoint(x: isOn ? self.backSwitch.bounds.width - self.backSwitch.bounds.height/2 : self.backSwitch.bounds.height/2, y: self.center.y)
                }, completion:nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8*backSwitch.duration, execute: { [unowned self] in
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.2*self.backSwitch.duration + 0.8)
                let color = self.backSwitch.on ? self.backSwitch.borderOnColor : self.backSwitch.borderOffColor
                self.borderLayer.strokeColor = color?.cgColor
                (self.backSwitch.borderLayer as? CAShapeLayer)?.strokeColor = color?.cgColor
                
                let bgColor = (self.backSwitch.on ? self.backSwitch.onBgColor : self.backSwitch.offBgColor)?.cgColor
                (self.backSwitch.bgLayer as? CAShapeLayer)?.fillColor = bgColor
                CATransaction.commit()
            })
            
            let rotate = POPCustomAnimation { (layer, anim) -> Bool in
                if let face = layer as? CALayer, let animation = anim {
                    
                    let delta = toValue-fromValue
                    let time = animation.currentTime - animation.beginTime;
                    
                    let rate = 0.8;
                    
                    if let x = self.layer.presentation()?.position.x {
                        if x - h/2 > self.borderLayer.lineWidth && w - h/2 - x > self.borderLayer.lineWidth {
                            self.maskLayer.position = CGPoint(x: h/2, y: h/2)
                        } else if x - h/2 <= self.borderLayer.lineWidth {
                            self.maskLayer.position = CGPoint(x: x + self.borderLayer.lineWidth*2, y: h/2)
                        } else {
                            self.maskLayer.position = CGPoint(x: x - w + h - self.borderLayer.lineWidth*2, y: h/2)
                        }
                    }
                    
                    if (time <= self.backSwitch.duration) {
                        let targetValue = fromValue + time/self.backSwitch.duration*delta*rate;
                        face.transform = CATransform3DMakeRotation(CGFloat(targetValue), 0, 1, 0);
                    } else if (time < self.backSwitch.duration + 0.5) {
                        let targetValue = fromValue + delta*rate + Spring_1_100_5_0((time-self.backSwitch.duration)*4)*delta*(1-rate);
                        face.transform = CATransform3DMakeRotation(CGFloat(targetValue), 0, 1, 0)
                    } else {
                        face.transform = CATransform3DMakeRotation(CGFloat(toValue), 0, 1, 0)
                        return false
                    }
                    return true
                }
                return false
            }
            rotate?.removedOnCompletion = true
            self.faceLayer.pop_add(rotate, forKey: nil)
        }
    }
    
    //MARK: ------------ Private ------------
    
    func configurateFaceLayer() -> Void {
        self.faceLayer?.removeFromSuperlayer()
        
        let w = backgroundLayer.bounds.size.width, ow = CGFloat(100), rate = w/ow;
        let leftEyeX = 38*rate, rightEyeX = w-leftEyeX;
        let eyeY = 36*rate, eyeZ = sqrt(pow(ow/2,2)-pow(ow/2-36,2))*rate;
        
        // 3D容器图层
        let container = CATransformLayer()
        container.frame    = CGRect(x: 0, y: 0, width: w, height: w)
        backgroundLayer.addSublayer(container)
        
        func generateEyeLayer(withCenter center: CGPoint) -> CALayer {
            let w = backgroundLayer.bounds.size.width
            
            let eye = CALayer()
            eye.frame = CGRect(x: 0, y: 0, width: 0.18*w, height: 0.15*w)
            eye.position = center
            eye.contents = fyswitch_image(named: "eye")?.cgImage
            eye.contentsGravity = kCAGravityResizeAspect;
            eye.isDoubleSided = false
            
            return eye
        }
        
        func generateMouthLayer(isSad: Bool) -> CALayer {
            let w = backgroundLayer.bounds.size.width
            
            let mouth = CALayer()
            mouth.frame = CGRect(x: 0, y: 0, width: 0.42*w, height: 0.22*w)
            mouth.position = CGPoint(x: w/2, y: 0.6*w)
            mouth.contents = fyswitch_image(named: isSad ? "sad_mouth" : "happy_mouth")?.cgImage
            mouth.isDoubleSided = false
            
            return mouth
        }
        
        // off状态
        let sadLeftEye          = generateEyeLayer(withCenter: CGPoint(x: leftEyeX, y: eyeY))
        sadLeftEye.transform    = CATransform3DTranslate(CATransform3DIdentity, 0, 0, eyeZ);
        container.addSublayer(sadLeftEye)
        
        let sadRightEye         = generateEyeLayer(withCenter: CGPoint(x: rightEyeX, y: eyeY))
        sadRightEye.transform   = CATransform3DTranslate(CATransform3DIdentity, 0, 0, eyeZ);
        container.addSublayer(sadRightEye)
        
        let sadMouth            = generateMouthLayer(isSad: true)
        sadMouth.transform      = CATransform3DTranslate(CATransform3DIdentity, 0, 0, eyeZ)
        container.addSublayer(sadMouth)
        
        // on状态
        var trans               = CATransform3DTranslate(CATransform3DIdentity, 0, 0, -eyeZ)
        trans                   = CATransform3DRotate(trans, .pi, 0, 1, 0)
        
        let happyLeftEye        = generateEyeLayer(withCenter: CGPoint(x: leftEyeX, y: eyeY))
        happyLeftEye.transform  = trans
        container.addSublayer(happyLeftEye)
        
        let happyRightEye       = generateEyeLayer(withCenter: CGPoint(x: rightEyeX, y: eyeY))
        happyRightEye.transform = trans
        container.addSublayer(happyRightEye)
        
        let happyMouth          = generateMouthLayer(isSad: false)
        happyMouth.transform    = trans
        container.addSublayer(happyMouth)
        
        self.faceLayer = container;
    }
}
