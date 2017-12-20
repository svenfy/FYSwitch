//
//  FYBorderLineStroke.swift
//  FYSwitch
//
//  Created by FuYong on 12/12/2017.
//  Copyright © 2017 FuYong. All rights reserved.
//

import UIKit
import ReactiveSwift

class FYBorderLineStroke: CALayer, ISwitch {
    lazy var offLayer: CAShapeLayer = {
        let off = CAShapeLayer()
        off.fillColor = UIColor.clear.cgColor
        off.strokeStart = 0.25
        off.zPosition = 2
        addSublayer(off)
        return off
    }()
    lazy var onLayer: CAShapeLayer = {
        let on = CAShapeLayer()
        on.fillColor = UIColor.clear.cgColor
        on.zPosition = 3
        addSublayer(on)
        return on
    }()
    
    @objc dynamic weak var backSwitch: FYSwitch! {
        didSet {
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.borderOnColor)).producer.startWithValues { [unowned self] in
                self.onLayer.strokeColor = $0?.cgColor
            }
            Property<UIColor?>.init(object: backSwitch, keyPath: #keyPath(FYSwitch.borderOffColor)).producer.startWithValues { [unowned self] in
                self.offLayer.strokeColor = $0?.cgColor
            }
        }
    }
    
    func adjustPosition(withBoundary boundary: CGRect) {
        if let backSwitch = self.backSwitch {
            frame = backSwitch.bounds
            onLayer.frame = boundary
            offLayer.frame = boundary
            
            configurateBorders()
        }
    }
    
    func toggle(to isOn: Bool, animated: Bool) {
        let (showLayer, hideLayer) = isOn ? (onLayer, offLayer) : (offLayer, onLayer)
        onLayer.zPosition = isOn ? 3 : 1
        
        if !animated {
            showLayer.strokeEnd = showLayer.strokeStart + 0.5
            hideLayer.strokeEnd = hideLayer.strokeStart
        }
        else {
            // on/off状态切换时线性渐变
            CATransaction.begin()
            CATransaction.setAnimationDuration(backSwitch.duration)
            CATransaction.setCompletionBlock {
                hideLayer.strokeEnd = hideLayer.strokeStart
            }
            showLayer.strokeEnd = showLayer.strokeStart + 0.5
            CATransaction.commit()
        }
    }
    
    func configurateBorders() {
        let (w, r) = (onLayer.bounds.width, onLayer.bounds.height/2)
        let (lc, rc) = (CGPoint(x: r, y: r), CGPoint(x: w-r, y: r))
        
        func generatePaht() -> UIBezierPath {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: r))
            path.addArc(withCenter: lc, radius: r, startAngle: .pi, endAngle: .pi*3/2, clockwise: true)
            path.addLine(to: CGPoint(x: w-r, y: 0))
            path.addArc(withCenter: rc, radius: r, startAngle: -.pi/2, endAngle: .pi/2, clockwise: true)
            path.addLine(to: CGPoint(x: r, y: r*2))
            path.addArc(withCenter: lc, radius: r, startAngle: .pi/2, endAngle: .pi*3/2, clockwise: true)
            path.addLine(to: CGPoint(x: w-r, y: 0))
            path.addArc(withCenter: rc, radius: r, startAngle: -.pi/2, endAngle: .pi/2, clockwise: true)
            path.addLine(to: CGPoint(x: r, y: r*2))
            path.addArc(withCenter: lc, radius: r, startAngle: .pi/2, endAngle: .pi, clockwise: true)
            return path
        }
        
        offLayer.path = generatePaht().cgPath
        onLayer.path = generatePaht().cgPath
        
        if backSwitch.on {
            offLayer.strokeEnd = offLayer.strokeStart
            onLayer.strokeEnd = onLayer.strokeStart + 0.5
        } else {
            offLayer.strokeEnd = offLayer.strokeStart + 0.5
            onLayer.strokeEnd = onLayer.strokeStart
        }
        
        onLayer.lineWidth = backSwitch.borderWidth
        offLayer.lineWidth = backSwitch.borderWidth
    }
}
