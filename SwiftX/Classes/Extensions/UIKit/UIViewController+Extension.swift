//
//  UIViewController+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/14.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

/// MARK: NavigationBar相关处理
public extension UIViewController {
    
    // 安全区域
    public var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return additionalSafeAreaInsets
        }
        return UIEdgeInsets.zero
    }
    
    // 是否隐藏NavigationBar
    static private var kNavigationBarHidden = "kNavigationBarHidden"
    internal var isTopBarHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &UIViewController.kNavigationBarHidden) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.kNavigationBarHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
            navigationController?.isNavigationBarHidden = newValue
        }
    }
    
    // 是否隐藏shasowImage
    static private var kNavigationBarShadowImageHidden = "kIsNavigationBarShadowImageHidden"
    public var isNavigationBarShadowImageHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &UIViewController.kNavigationBarShadowImageHidden) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.kNavigationBarShadowImageHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
            configNavigationBarShadow(newValue)
        }
    }
    
    fileprivate func configNavigationBarShadow(_ hidden: Bool) {
        navigationController?.navigationBar.setBackgroundImage(hidden ? UIImage() : nil, for: .default)
        navigationController?.navigationBar.shadowImage = hidden ? UIImage() : nil
    }
    
    // 是否将navigationbar 半透明
    static private var kNavigationBarTranslucent = "kNavigationBarTranslucent"
    public var isNavigationBarTranslucent: Bool {
        get {
            return objc_getAssociatedObject(self, &UIViewController.kNavigationBarTranslucent) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.kNavigationBarTranslucent, newValue, .OBJC_ASSOCIATION_ASSIGN)
            configNavigationBarTransparency(newValue)
            isNavigationBarShadowImageHidden = newValue
        }
    }
    
    fileprivate func configNavigationBarTransparency(_ translucent: Bool) {
        navigationController?.navigationBar.backgroundColor = translucent ? UIColor.clear : nil
        navigationController?.navigationBar.isTranslucent = translucent
    }
}

/// MARK: UINavigationItem
public extension UIViewController {
    
    public func leftBarButtonItem(title: String?, size: CGSize = CGSize(width: 80, height: 44), handler: ((_ button: UIButton) -> Void)? = nil) -> UIBarButtonItem {
        return customBarButtonItem(options:[
                                        .title(title, UIColor(hexColor: "#5495ff"), .normal),
                                        .title(title, UIColor(hexColor: "#a0a0a5"), .disabled),
                                        .title(title, UIColor(hexColor: "#5495ff").withAlphaComponent(0.7), .highlighted)
                                    ],
                                   size: size,
                                   isBackItem: false,
                                   left: true,
                                   handler: handler)
    }
    
    public func rightBarButtonItem(title: String?, size: CGSize = CGSize(width: 80, height: 44), handler: ((_ button: UIButton) -> Void)? = nil) -> UIBarButtonItem {
        return customBarButtonItem(options:[
                                        .title(title, UIColor(hexColor: "#5495ff"), .normal),
                                        .title(title, UIColor(hexColor: "#a0a0a5"), .disabled),
                                        .title(title, UIColor(hexColor: "#5495ff").withAlphaComponent(0.7), .highlighted)
                                    ],
                                   size: size,
                                   isBackItem: false,
                                   left: false,
                                   handler: handler)
    }
    
    public func leftBarButtonItem(image: UIImage?, size: CGSize = CGSize(width: 44, height: 44), isBackItem: Bool = false, handler: ((_ button: UIButton) -> Void)? = nil) -> UIBarButtonItem {
        return customBarButtonItem(options: [.image(image, .normal)], size: size, isBackItem: isBackItem, left: true, handler: handler)
    }
    
    public func rightBarButtonItem(image: UIImage?, size: CGSize = CGSize(width: 44, height: 44), handler: ((_ button: UIButton) -> Void)? = nil) -> UIBarButtonItem {
        return customBarButtonItem(options: [.image(image, .normal)], size: size, isBackItem: false, left: false, handler: handler)
    }
    
    public func customBarButtonItem(options: [UIControlStateOption], size: CGSize = CGSize(width: 80, height: 44), isBackItem: Bool = false, left: Bool = true, handler: ((_ button: UIButton) -> Void)? = nil) -> UIBarButtonItem {
        guard options.count != 0 else { return UIBarButtonItem() }
        let button = CustomBarButton(frame: CGRect.zero)
        if isBackItem {
            button.tag = UIViewController.kBackItemTag
        }
        button.contentHorizontalAlignment = left ? .left : .right
        button.handler = handler
        if case .title(_, _, _) = options[0] {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.frame = CGRect(origin: CGPoint.zero, size: size)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: left ? 0 : -4, bottom: 0, right: left ? 0 : -4)
        } else {
            button.frame = CGRect(origin: CGPoint.zero, size: size)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: left ? -1 : 0, bottom: 0, right: left ? 0 : -1)
            button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        }
        
        for option in options {
            switch option {
            case .title(let title, let color, let state):
                button.setTitle(title, for: state)
                button.setTitleColor(color, for: state)
            case .image(let image, let state):
                button.setImage(image, for: state)
            }
        }
        return UIBarButtonItem(customView: button)
    }
    
    // UIBarButtonItem 自定义
    public enum UIControlStateOption {
        case title(String?, UIColor?, UIControl.State)
        case image(UIImage?, UIControl.State)
    }
    
    fileprivate class CustomBarButton: UIButton {
        
        var handler: ((_ button: UIButton) -> Void)? {
            didSet {
                addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func buttonAction() {
            handler?(self)
        }
    }
    static internal var kBackItemTag = Int.max / 3 + 1
}

/// MARK: 点击空白处键盘处理
public extension UIViewController {
    static private var kKeyboardGesture = "kKeyboardGesture"
    
    public func registerKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public func unregisterKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private var tapGesture: UITapGestureRecognizer {
        if let gesture = objc_getAssociatedObject(self, UIViewController.kKeyboardGesture) as? UITapGestureRecognizer {
            return gesture
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(gestureAction(_:)))
        objc_setAssociatedObject(self, UIViewController.kKeyboardGesture, gesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return gesture
    }

    @objc private func gestureAction(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow() {
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func keyboardWillHide() {
        view.removeGestureRecognizer(tapGesture)
    }
    
}
