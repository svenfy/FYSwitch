//
//  FY3DBlinkRotateKnob.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/18.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import ReactiveSwift

class FY3DBlinkRotateKnob: UIView, IKnob, CAAnimationDelegate {

    lazy var backgroundLayer: CALayer = {
        var layer = CALayer()
        layer.masksToBounds = true
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    lazy var shadowLayer: CALayer = {
        var layer = CALayer()
        backgroundLayer.insertSublayer(layer, at: 0)
        return layer
    }()
    var faceLayer: CATransformLayer!
    
    var offLeftEye: CAShapeLayer!
    var offRightEye: CAShapeLayer!
    var onLeftEye: CAShapeLayer!
    var onRightEye: CAShapeLayer!

    //MARK: ------------ IKnob ------------
    @objc dynamic weak var backSwitch: FYSwitch!
    
    func adjustPosition(withBoundary frame: CGRect) {
        if let backSwitch = self.backSwitch {
            let newFrame = CGRect(origin: CGPoint(x: backSwitch.on ? frame.maxX - frame.height : frame.minX, y: frame.minY),
                                  size: CGSize(width: frame.height, height: frame.height))
            self.frame = newFrame
            
            backgroundLayer.frame = bounds
            backgroundLayer.cornerRadius = bounds.height/2
            shadowLayer.frame = bounds
            shadowLayer.cornerRadius = bounds.height/2
            
            configurateFaceLayer()
            toggle(to: backSwitch.on, animated: false)
        }
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        let w = self.backSwitch.bounds.width, h = self.backSwitch.bounds.height
        if !animated {
            self.center = CGPoint(x: isOn ? w-h/2 : h/2, y: self.center.y)
            
            shadowLayer.position = CGPoint(x: h/2 + (isOn ? -1 : 1)*0.0248*h, y: h/2 - 0.05*h)
            
            if isOn {
                backgroundLayer.backgroundColor = UIColor(red: 48/255.0, green: 182/255.0, blue: 90/255.0, alpha: 1).cgColor
                shadowLayer.backgroundColor = UIColor(red: 12/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1).cgColor
            } else {
                backgroundLayer.backgroundColor = UIColor(red: 181/255.0, green: 17/255.0, blue: 53/255.0, alpha: 1).cgColor
                shadowLayer.backgroundColor = UIColor(red: 215/255.0, green: 0/255.0, blue: 48/255.0, alpha: 1).cgColor
            }
            
            faceLayer.transform = CATransform3DMakeRotation(isOn ? -.pi*2 : .pi, 0, 1, 0)
        }
        else {
            let h = bounds.height
            
            let eyeRadius = 0.058*h
            let anim = CAKeyframeAnimation(keyPath: "path")
            
            anim.values = [UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: eyeRadius*2, height: eyeRadius*2)).cgPath,
                           UIBezierPath(ovalIn: CGRect(x: 0, y: eyeRadius-1, width: eyeRadius*2, height: 2)).cgPath,
                           UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: eyeRadius*2, height: eyeRadius*2)).cgPath,
                          ]
            anim.keyTimes = [0, 0.5, 1]
            anim.fillMode = kCAFillModeBoth;
            anim.duration = 0.2;
            anim.delegate = self;
            anim.setValue(isOn, forKey: "on")
            anim.isRemovedOnCompletion = true
            
            if (isOn) {   // 悲伤 => 开心
                offLeftEye.add(anim, forKey: "blink")
                anim.delegate = nil
                offRightEye.add(anim, forKey: "blink2")
            } else {
                onLeftEye.add(anim, forKey: "blink")
                anim.delegate = nil
                onRightEye.add(anim, forKey: "blink2")
            }
        }
    }
    
    //MARK: ------------ CAAnimationDelegate ------------
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let w = self.backSwitch.bounds.width, h = self.backSwitch.bounds.height
        let isOn = anim.value(forKey: "on") as! Bool
        
        UIView.animate(withDuration: backSwitch.duration, animations: { [unowned self] in
                self.center = CGPoint(x: isOn ? w - h/2 : h/2, y: self.center.y)
            }, completion:nil)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(backSwitch.duration - 0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))

        faceLayer.transform = CATransform3DMakeRotation(isOn ? -.pi*2 : .pi, 0, 1, 0)
        shadowLayer.position = CGPoint(x: h/2 + (isOn ? -1 : 1)*0.0248*h, y: h/2 - 0.05*h)
        
        if isOn {
            backgroundLayer.backgroundColor = UIColor(red: 48/255.0, green: 182/255.0, blue: 90/255.0, alpha: 1).cgColor
            shadowLayer.backgroundColor = UIColor(red: 12/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1).cgColor
        } else {
            backgroundLayer.backgroundColor = UIColor(red: 181/255.0, green: 17/255.0, blue: 53/255.0, alpha: 1).cgColor
            shadowLayer.backgroundColor = UIColor(red: 215/255.0, green: 0/255.0, blue: 48/255.0, alpha: 1).cgColor
        }
        
        CATransaction.commit()
    }
    
    //MARK: ------------ Private ------------
    
    func configurateFaceLayer() -> Void {
        self.faceLayer?.removeFromSuperlayer()
        
        let h = bounds.height, ow = CGFloat(100), rate = h/ow;
        
        func generateEyeLayer(withCenter center: CGPoint) -> CAShapeLayer {
            let eyeRadius = 0.058*h
            let eye = CAShapeLayer()
            eye.frame = CGRect(x: 0, y: 0, width: eyeRadius*2, height: eyeRadius*2)
            eye.position = center
            eye.isDoubleSided = false
            eye.path = UIBezierPath(ovalIn: eye.bounds).cgPath
            eye.fillColor = UIColor.white.cgColor
            return eye;
        }
        
        func generateMouthLayer(isSad: Bool) -> CALayer {
            let mouthRadius = 0.157*h
            let mouth = CAShapeLayer()
            mouth.frame = CGRect(x: 0, y: 0, width: mouthRadius*2, height: mouthRadius*2)
            mouth.position = CGPoint(x: h/2, y: 0.74*h)
            mouth.isDoubleSided = false
            
            var path: UIBezierPath;
            if (isSad) {
                path = UIBezierPath(arcCenter: CGPoint(x: mouthRadius, y: mouthRadius), radius: mouthRadius, startAngle: -.pi, endAngle: 0, clockwise: true)
            } else {
                path = UIBezierPath(arcCenter: CGPoint(x: mouthRadius, y: 0), radius: mouthRadius, startAngle: 0, endAngle: .pi, clockwise: true)
            }
            path.close()
            mouth.path = path.cgPath
            mouth.fillColor = UIColor.white.cgColor
            
            return mouth;
        }
        
        let (leftEyeX, rightEyeX) = (0.369*h, (1-0.369)*h)
        let eyeY = 0.456*h, eyeZ = 0.5*h
        
        // 3D容器图层
        let container = CATransformLayer()
        container.frame    = CGRect(x: 0, y: 0, width: h, height: h)
        backgroundLayer.addSublayer(container)
        
        // off状态
        let sadLeftEye          = generateEyeLayer(withCenter: CGPoint(x: leftEyeX, y: eyeY))
        sadLeftEye.transform    = CATransform3DTranslate(CATransform3DIdentity, 0, 0, eyeZ);
        container.addSublayer(sadLeftEye)
        
        let sadRightEye         = generateEyeLayer(withCenter: CGPoint(x: rightEyeX, y: eyeY))
        sadRightEye.transform   = CATransform3DTranslate(CATransform3DIdentity, 0, 0, eyeZ);
        container.addSublayer(sadRightEye)
        
        let sadMouth            = generateMouthLayer(isSad: false)
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
        
        let happyMouth          = generateMouthLayer(isSad: true)
        happyMouth.transform    = trans
        container.addSublayer(happyMouth)
        
        onLeftEye  = sadLeftEye
        onRightEye = sadRightEye
        offLeftEye   = happyLeftEye
        offRightEye  = happyRightEye
        
        container.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
        self.faceLayer = container;
    }
}
