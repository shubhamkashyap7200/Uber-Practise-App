//
//  CircularProgressView.swift
//  Uber Practise App
//
//  Created by Shubham on 12/24/22.
//

import UIKit


class CircularProgressView: UIView {
    // MARK: - Properties
    var progressLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    
    // MARK: - Lifecycle Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCircleLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - Helper Functions
    private func configureCircleLayers() {
        pulsatingLayer = circleShapeLayer(stroke: .clear, fillColor: .systemBlue)
        layer.addSublayer(pulsatingLayer)
        
        trackLayer = circleShapeLayer(stroke: .clear, fillColor: .clear)
        layer.addSublayer(trackLayer)
        trackLayer.strokeEnd = 1.0
        
        progressLayer = circleShapeLayer(stroke: .systemPink, fillColor: .clear)
        layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1.0
    }
    
    private func circleShapeLayer(stroke: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 32.0)
        let circularPath = UIBezierPath(arcCenter: center, radius: self.frame.width / 2.5, startAngle: -(.pi / 2), endAngle: 1.5 * .pi, clockwise: true)
        
        layer.path = circularPath.cgPath
        layer.strokeColor = stroke.cgColor
        layer.lineWidth = 12.0
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center
        return layer
    }
    
    func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    func setProgressWithAnimation(withDuration duration: TimeInterval, withValue value: Float, completion: @escaping() -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 1.0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgress")
        
        CATransaction.commit()
    }
}
