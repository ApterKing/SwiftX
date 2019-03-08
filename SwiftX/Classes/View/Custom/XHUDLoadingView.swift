//
//  XHUDLoadingView.swift
//  SwiftX
//
//  Created by wangcong on 2019/3/8.
//

import UIKit

final public class XHUDLoadingView: UIView {
    
    private lazy var opacityView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.alpha = 0.01
        return view
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        return indicator
    }()
    private lazy var hudView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.addSubview(indicatorView)
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addSubview(indicatorView)
        return view
    }()
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(opacityView)
        addSubview(hudView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        opacityView.frame = bounds
        let hudWideHight: CGFloat = 160
        hudView.frame = CGRect(x: (width - hudWideHight) / 2.0, y: (height - hudWideHight) / 2.0, width: hudWideHight, height: hudWideHight)
        indicatorView.center = CGPoint(x: hudView.width / 2.0, y: hudView.height / 2.0)
    }
    
}

public extension XHUDLoadingView {
    
    public func startAnimation() {
        indicatorView.startAnimating()
    }
    
    public func stopAnimation() {
        indicatorView.stopAnimating()
    }
    
}
