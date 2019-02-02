//
//  XQRCodeAnimationView.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/30.
//  Copyright © 2018 wangcong. All rights reserved.
//


import UIKit

/// MARK: 二维码扫描时动画view
class XQRCodeAnimationView: UIView {
    
    private lazy var imageView = UIImageView()
    private var isAnimating = false
    private var animateRect = CGRect.zero
    
    var animateImage: UIImage? {
        didSet {
            imageView.image = animateImage
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        imageView.frame = bounds
        super.layoutSubviews()
    }
    
    deinit {
        stopAnimation()
    }
}

extension XQRCodeAnimationView {
    
    func startAnimation(in rect: CGRect) {
        isAnimating = true
        animateRect = rect
        stepAnimation()
    }
    
    func stopAnimation() {
        isAnimating = false
    }
    
    @objc private func stepAnimation() {
        guard let image = animateImage, isAnimating else { return }
        let h = image.size.height * (animateRect.width / image.size.width)
        
        var frame = animateRect
        frame.y -= h
        frame.height = h
        self.frame = frame
        alpha = 0.0
        UIView.animate(withDuration: 1.2, animations: {
            self.alpha = 1.0
            var frame = self.animateRect
            frame.y += frame.height - h
            frame.height = h
            self.frame = frame
        }) { (finish) in
            self.perform(#selector(XQRCodeAnimationView.stepAnimation), with: nil, afterDelay: 0.3)
        }
    }
}
