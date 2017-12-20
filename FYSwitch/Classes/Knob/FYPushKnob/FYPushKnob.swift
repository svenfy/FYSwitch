//
//  FYPushKnob.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/19.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import pop

class FYPushKnob: UIView, IKnob, POPAnimationDelegate {
    lazy var onImageView: UIImageView = {
        let imageView = UIImageView(image: fyswitch_image(named: "push_check"))
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        return imageView
    }()
    lazy var offImageView: UIImageView = {
        let imageView = UIImageView(image: fyswitch_image(named: "push_delete"))
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        return imageView
    }()
    
    var onMaskLayer = CALayer()
    var offMaskLayer = CALayer()
    
    //MARK: ------------ IKnob ------------
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            backgroundColor = .white
            layer.cornerRadius = 5
            
            onImageView.layer.addSublayer(onMaskLayer)
            offImageView.layer.addSublayer(offMaskLayer)
            onImageView.layer.mask = onMaskLayer
            offImageView.layer.mask = offMaskLayer
            
            onMaskLayer.backgroundColor = UIColor.white.cgColor
            offMaskLayer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        bounds = CGRect(origin: .zero,
                        size: CGSize(width: 48/104*backSwitch.bounds.width, height: boundary.height))
        onImageView.frame = CGRect(x: -bounds.width, y: 0, width: bounds.width, height: bounds.height)
        offImageView.frame = CGRect(x: bounds.width, y: 0, width: bounds.width, height: bounds.height)
        onMaskLayer.position = CGPoint(x: 20/48*bounds.width, y: 24/34*bounds.height)
        offMaskLayer.position = CGPoint(x: bounds.width/2, y: bounds.width/2)
        
        toggle(to: backSwitch.on, animated: false)
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        let targetCenter = CGPoint(x: isOn ? backSwitch.bounds.width - bounds.width/2 - backSwitch.knobMargin : bounds.width/2 + backSwitch.knobMargin, y: self.backSwitch.bounds.height/2)
        
        let (showMask, hideMask) = isOn ? (onMaskLayer, offMaskLayer) : (offMaskLayer, onMaskLayer)
        let targetMaskBounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width)
        
        if !animated {
            self.center = targetCenter
            showMask.bounds = targetMaskBounds
            hideMask.bounds = .zero
        }
        else {
            showMask.bounds = .zero
            showMask.cornerRadius = 0
            UIView.animate(withDuration: 0.4*backSwitch.duration, animations: {
                self.center = targetCenter
            }, completion: { (finished) in
                if finished {
                    self.maskAnimation(showMask, isOn: isOn)
                }
            })
        }
    }
    
    func maskAnimation(_ showMask: CALayer, isOn: Bool) {
        let targetMaskBounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width)
        
        let resize = POPBasicAnimation(propertyNamed: kPOPLayerSize)
        resize?.toValue = targetMaskBounds.size
        resize?.duration = 0.3*self.backSwitch.duration
        resize?.delegate = self
        resize?.setValue(isOn, forKey: "isOn")
        showMask.pop_add(resize, forKey: "resize")
        
        let radius = POPBasicAnimation(propertyNamed: kPOPLayerCornerRadius)
        radius?.toValue = targetMaskBounds.height/2
        radius?.duration = 0.3*self.backSwitch.duration
        showMask.pop_add(radius, forKey: "radius")
    }
    
    func pop_animationDidStop(_ anim: POPAnimation!, finished: Bool) {
        if let isOn = anim.value(forKey: "isOn") as? Bool {
            if isOn {
                UIView.animateKeyframes(withDuration: 0.3*backSwitch.duration, delay: 0, options: .allowUserInteraction, animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                        self.onImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                        self.onImageView.transform = .identity
                    })
                }, completion: nil)
            }
            else {
                UIView.animateKeyframes(withDuration: 0.3*backSwitch.duration, delay: 0, options: .allowUserInteraction, animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                        self.offImageView.transform = CGAffineTransform(rotationAngle: .pi)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                        self.offImageView.transform = CGAffineTransform(rotationAngle: .pi*2)
                    })
                }, completion: nil)
            }
        }
    }
}
