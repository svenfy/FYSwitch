//
//  FYScaleKnob.swift
//  FYSwitch
//
//  Created by Fu Yong on 2017/12/19.
//  Copyright © 2017年 Jedark. All rights reserved.
//

import UIKit
import ReactiveSwift

class FYScaleKnob: UIImageView, IKnob {
    lazy var onImageView: UIImageView = {
        let imageView = UIImageView()
        addSubview(imageView)
        return imageView
    }()
    lazy var offImageView: UIImageView = {
        let imageView = UIImageView()
        addSubview(imageView)
        return imageView
    }()
    
    //MARK: ------------ IKnob ------------
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIImage?>.init(object: backSwitch, keyPath: #keyPath(FYImageTextSwitch.knobOnImage)).producer.startWithValues { (image) in
                self.onImageView.image = image
            }
            Property<UIImage?>.init(object: backSwitch, keyPath: #keyPath(FYImageTextSwitch.knobOffImage)).producer.startWithValues { (image) in
                self.offImageView.image = image
            }
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        bounds = CGRect(origin: .zero,
                        size: CGSize(width: boundary.height, height: boundary.height))
        
        onImageView.frame = bounds
        offImageView.frame = bounds
        
        toggle(to: backSwitch.on, animated: false)
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        if let backSwitch = backSwitch as? FYImageTextSwitch {
            let (showView, hideView) = isOn ? (onImageView, offImageView) : (offImageView, onImageView)
            let targetCenter = CGPoint(x: isOn ? self.backSwitch.bounds.width - self.backSwitch.bounds.height/2 : self.backSwitch.bounds.height/2, y: self.backSwitch.bounds.height/2)
            
            if !animated {
                self.center = targetCenter
                showView.alpha = 1
                hideView.alpha = 0
            }
            else {
                UIView.animateKeyframes(withDuration: backSwitch.duration, delay: 0, options: .allowUserInteraction, animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1, animations: {
                        self.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.495, relativeDuration: 0.01, animations: {
                        showView.alpha = 1
                        hideView.alpha = 0
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.1, animations: {
                        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
                        self.transform = CGAffineTransform.identity
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.8, animations: {
                        self.center = targetCenter
                    })
                }, completion: nil)
            }
        }
    }
}
