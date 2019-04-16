//
//  XLoadingView.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/23.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

@objc public protocol XLoadingViewDelegate: NSObjectProtocol {
    
    // 点击事件
    @objc optional func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool
    @objc optional func loadingViewDidTapped(_ loadingView: XLoadingView)
    
    // 设置提示
    @objc optional func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage?
    @objc optional func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString?
    
    // 下方按钮
    @objc optional func loadingViewTitleForButton(_ loadingView: XLoadingView) -> String?
    @objc optional func loadingViewButtonDidTapped(_ loadingView: XLoadingView)
    
}

open class XLoadingView: UIView {
    
    public enum State: String {
        case success = "加载成功"
        case error = "加载失败，请检查网络"
        case loading = "加载中..."
        case empty = "暂无数据"
    }
    
    // 加载
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.addSubview(loadingImageView)
        view.addSubview(loadingShadowImageView)
        return view
    }()
    private lazy var loadingImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "icon_loading", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        imgv.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 18, height: 18))
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    private lazy var loadingShadowImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "icon_loading_shadow", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        imgv.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 8))
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    
    // 提示
    private lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(promptImageView)
        view.addSubview(promptLabel)
        view.addSubview(promptButton)
        return view
    }()
    private lazy var promptImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "icon_prompt", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        imgv.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 120, height: 120))
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private lazy var promptButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hexColor: "#66B30C"), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor(hexColor: "#66B30C").cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.isHidden = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(_buttonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(_tapAction))
        return gesture
    }()
    private var isUp = true
    
    /// MARK: outter
    open var delegate: XLoadingViewDelegate? {
        didSet {
            if delegate?.loadingViewShouldEnableTap?(self) ?? false {
                contentView.addGestureRecognizer(tapGesture)
            }
        }
    }
    open var state: XLoadingView.State = .loading {
        didSet {
            _resetState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(contentView)
        addSubview(loadingView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds

        loadingView.frame = CGRect(x: (width - 40) / 2.0, y: (height - 80) / 2.0, width: 40, height: 80)
        loadingShadowImageView.frame = CGRect(origin: CGPoint(x: (loadingView.width - loadingShadowImageView.width) / 2.0, y: loadingView.height - loadingShadowImageView.height), size: loadingShadowImageView.frame.size)
        loadingImageView.frame = CGRect(origin: CGPoint(x: (loadingView.width - loadingImageView.width) / 2.0, y: loadingShadowImageView.top - loadingImageView.height), size: loadingImageView.frame.size)
        
        _resetState()
    }
    
    deinit {
    }
}

extension XLoadingView {
    
    @objc private func _resetState() {
        if state == .loading {
            _startAnimate()
            contentView.isHidden = true
            loadingView.isHidden = false
        } else {
            _stopAnimate()
            contentView.isHidden = false
            loadingView.isHidden = true
        }
        
        if let image = delegate?.loadingViewPromptImage?(self) {
            promptImageView.image = image
        } else {
            promptImageView.image = UIImage(named: "icon_prompt", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        }
        promptImageView.frame = CGRect(origin: CGPoint(x: (contentView.width - promptImageView.width) / 2.0, y: (contentView.height - promptImageView.height) / 2.0 - 80), size: promptImageView.frame.size)
        
        if let text = delegate?.loadingViewPromptText?(self) {
            promptLabel.attributedText = text
        } else {
            promptLabel.text = state.rawValue
        }
        promptLabel.frame = CGRect(x: 0, y: promptImageView.top + promptImageView.height + 20, width: contentView.width, height: 40)
        
        var size = CGSize.zero
        if let title = delegate?.loadingViewTitleForButton?(self) {
            size = title.boundingSize(with: CGSize(width: UIScreen.width, height: 44), font: promptButton.titleLabel?.font ?? UIFont.systemFont(ofSize: 14))
            promptButton.frame = CGRect(x: (UIScreen.width - size.width - 50) / 2.0, y: promptLabel.y + promptLabel.height + 20, width: size.width + 50, height: 34)
            promptButton.setTitle(title, for: .normal)
            promptButton.isHidden = false
        } else {
            promptButton.isHidden = true
        }
    }
    
    @objc private func _tapAction() {
        delegate?.loadingViewDidTapped?(self)
    }
    
    @objc private func _buttonAction() {
        delegate?.loadingViewButtonDidTapped?(self)
    }
    
    @objc private func _startAnimate() {
        loadingImageView.isHidden = false
        loadingImageView.frame = CGRect(origin: CGPoint(x: (loadingView.width - loadingImageView.width) / 2.0, y: loadingShadowImageView.top - loadingImageView.height), size: loadingImageView.frame.size)
        
        var endCenter = loadingImageView.center
        endCenter.y -= 40
        let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.75, delay: 0, options: UIView.AnimationOptions(rawValue: AnimationOptions.repeat.rawValue | AnimationOptions.autoreverse.rawValue), animations: {
            self.loadingImageView.center = endCenter
            self.loadingImageView.transform = transform
        }, completion: nil)
    }
    
    @objc private func _stopAnimate() {
        loadingImageView.isHidden = true
    }
    
}
