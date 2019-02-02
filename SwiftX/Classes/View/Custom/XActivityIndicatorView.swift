//
//  XActivityIndicatorView.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/30.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

/// MARK: 仿原生的UIActivityIndicatorView，增加预刷新进度，通过strokeEnd来控制
open class XActivityIndicatorView: UIView {
    var isAnimating: Bool {
        get {
            return _isAnimating
        }
    }
    var color: UIColor = UIColor.white {
        didSet {
            _preIndicatorLayer.color = color
            _indicatorLayer.color = color
            _indicatorLayer.highlightColor = color
            guard let maskLayer = layer.mask as? CAShapeLayer else { return }
            maskLayer.strokeColor = color.cgColor
        }
    }
    var strokeStart: CGFloat = 0.0 {
        didSet {
            guard let maskLayer = layer.mask as? CAShapeLayer else { return }
            maskLayer.strokeStart = strokeStart
        }
    }
    var strokeEnd: CGFloat = 1.0 {
        didSet {
            guard let maskLayer = layer.mask as? CAShapeLayer else { return }
            maskLayer.strokeEnd = strokeEnd
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _initUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _initUI()
    }
    
    deinit {
        _displayLink.invalidate()
        _displayLink = nil
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.size.width
        let height = bounds.size.height
        _preIndicatorLayer.center = CGPoint(x: width / 2.0, y: height / 2.0)
        _indicatorLayer.center = _preIndicatorLayer.center
    }
    
    /// 私有属性
    private let _preIndicatorLayer = XIndicatorLayer()
    private let _indicatorLayer = XIndicatorLayer()
    private var _isAnimating = false
    private var _displayLink: CADisplayLink!
}

public extension XActivityIndicatorView {
    
    private func _initUI() {
        backgroundColor = UIColor.clear
        
        let outterRadius = _preIndicatorLayer.outterRadius
        let originCenter = center
        self.frame = CGRect(x: 0, y: 0, width: 2 * outterRadius, height: 2 * outterRadius)
        self.center = originCenter
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(arcCenter: CGPoint(x: outterRadius, y: outterRadius), radius: outterRadius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2 * 3, clockwise: true).cgPath
        maskLayer.lineWidth = outterRadius * 2
        maskLayer.strokeColor = UIColor.red.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeEnd = 0.75
        layer.mask = maskLayer
        strokeEnd = 0.0
        
        _preIndicatorLayer.frame = bounds
        _preIndicatorLayer.backgroundColor = UIColor.clear
        addSubview(_preIndicatorLayer)
        _preIndicatorLayer.setNeedsDisplay()
        
        _indicatorLayer.isHidden = true
        _indicatorLayer.backgroundColor = UIColor.clear
        _indicatorLayer.frame = _preIndicatorLayer.frame
        _indicatorLayer.color = color.withAlphaComponent(0.5)
        _indicatorLayer.hightAlphaGradient = 0.1
        _indicatorLayer.highlightRange = 9..<12
        _indicatorLayer.highlightColor = color
        insertSubview(_indicatorLayer, belowSubview: _preIndicatorLayer)
        _indicatorLayer.setNeedsDisplay()
        
        _displayLink = CADisplayLink(target: self, selector: #selector(_redrawAction))
        _displayLink.add(to: .current, forMode: .default)
        if #available(iOS 10, *) {
            _displayLink.preferredFramesPerSecond = 20
        } else {
            _displayLink.frameInterval = 20
        }
        _displayLink.isPaused = true
    }
    
    @objc func _redrawAction() {
        let range = _indicatorLayer.highlightRange
        _indicatorLayer.highlightRange = (range.lowerBound + 1)..<(range.upperBound + 1)
        _indicatorLayer.setNeedsDisplay()
    }
}

public extension XActivityIndicatorView {
    public func startAnimation() {
        guard _isAnimating == false else { return }
        _isAnimating = true
        _preIndicatorLayer.isHidden = true
        _indicatorLayer.isHidden = false
        
        _displayLink.isPaused = false
    }
    
    public func stopAnimation() {
        _displayLink.isPaused = true
        
        _preIndicatorLayer.isHidden = false
        _indicatorLayer.isHidden = true
        _indicatorLayer.highlightRange = 9..<12
        _indicatorLayer.setNeedsDisplay()
        _isAnimating = false
    }
}

extension XActivityIndicatorView {
    
    class XIndicatorLayer: UIView {
        
        fileprivate let outterRadius: CGFloat = 14
        fileprivate let innerRadius: CGFloat = 8
        fileprivate let lineWidth: CGFloat = 2.5
        
        var highlightRange = 0..<0 {
            didSet{
                setNeedsDisplay()
            }
        }
        var highlightColor = UIColor.white {
            didSet {
                setNeedsDisplay()
            }
        }
        var hightAlphaGradient: CGFloat = 0.0 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        var color: UIColor = UIColor.white {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override func draw(_ rect: CGRect) {
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            ctx.setLineWidth(lineWidth)
            ctx.setLineCap(CGLineCap.round)
            for i in 0..<12 {
                let x = cos(CGFloat.pi / 2.0 - CGFloat(i) * 30.0 * CGFloat.pi / 180.0)
                let y = sin(CGFloat.pi / 2.0 - CGFloat(i) * 30.0 * CGFloat.pi / 180.0)
                
                let realOutterRadius = outterRadius - lineWidth / 2.0
                let from = CGPoint(x: realOutterRadius + x * realOutterRadius + lineWidth / 2.0, y: realOutterRadius - y * realOutterRadius + lineWidth / 2.0)
                let to = CGPoint(x: realOutterRadius + x * innerRadius + lineWidth / 2.0, y: realOutterRadius - y * innerRadius + lineWidth / 2.0)
                ctx.saveGState()
                var alphaColor = color
                for (index, highlight) in highlightRange.enumerated().reversed() {
                    if highlight % 12 == i {
                        alphaColor = highlightColor.withAlphaComponent(1 - CGFloat(index) * hightAlphaGradient)
                        break
                    }
                }
                ctx.setStrokeColor(alphaColor.cgColor)
                ctx.move(to: from)
                ctx.addLine(to: to)
                ctx.strokePath()
                ctx.restoreGState()
            }
        }
    }
    
}
