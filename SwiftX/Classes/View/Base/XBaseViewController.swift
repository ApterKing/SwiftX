//
//  XBaseViewController.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/16.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

/// MARK: 加载动画/navigationBar返回键处理
open class XBaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // navigationItem back
    public var navigationItemBackStyle = UINavigationItemBackStyle.backGray {
        didSet {
            if let items = navigationItem.leftBarButtonItems {
                for item in items {
                    if let button = item.customView as? UIButton, button.tag == UIViewController.kBackItemTag {
                        if navigationItemBackStyle == .none {
                            navigationItem.leftBarButtonItems?.remove(element: item)
                            return
                        }
                        var imageName = "icon_nav_back_gray"
                        switch navigationItemBackStyle {
                        case .backGray:
                            imageName = "icon_nav_back_gray"
                        case .backWhite:
                            imageName = "icon_nav_back_white"
                        case .closeGray:
                            imageName = "icon_nav_close_gray"
                        default:
                            imageName = "icon_nav_close_white"
                        }
                        button.setImage(UIImage(named: imageName, in: Bundle(for: XBaseViewController.self), compatibleWith: nil), for: .normal)
                        break
                    }
                }
            } else {
                showBackNavigationItem()
            }
        }
    }
    public enum UINavigationItemBackStyle: Int {
        case none        // 取消显示返回键
        case backGray    // 灰色返回  <
        case backWhite   // 白色返回  <
        case closeGray   // 灰色关闭  x
        case closeWhite  // 白色关闭  x
    }
    
    // loading
    private lazy var loadingView: XLoadingView = {
        let loadingView = XLoadingView(frame: CGRect.zero)
        loadingView.state = .loading
        loadingView.delegate = self
        return loadingView
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false
        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        guard navigationController?.viewControllers.count ?? 0 > 1 else { return }
        showBackNavigationItem()
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override open func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isTopBarHidden = navigationController?.isNavigationBarHidden ?? false
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if navigationController != nil {
            navigationController?.setNavigationBarHidden(isTopBarHidden, animated: true)
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override open var shouldAutorotate: Bool {
        return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

}

extension XBaseViewController {
    
    private func showBackNavigationItem() {
        var imageName = "icon_nav_back_gray"
        switch navigationItemBackStyle {
        case .backGray:
            imageName = "icon_nav_back_gray"
        case .backWhite:
            imageName = "icon_nav_back_white"
        case .closeGray:
            imageName = "icon_nav_close_gray"
        default:
            imageName = "icon_nav_close_white"
        }
        var leftBarButtonItems = navigationItem.leftBarButtonItems ?? []
        leftBarButtonItems.insert(leftBarButtonItem(image: UIImage(named: imageName, in: Bundle(for: XBaseViewController.self), compatibleWith: nil), isBackItem: true, handler: { [weak self] (_) in
            self?.goBack()
        }), at: 0)
        navigationItem.leftBarButtonItems = leftBarButtonItems
    }
    
}

extension XBaseViewController {
    
    func startAnimation() {
        if loadingView.superview == nil {
            view.addSubview(loadingView)
            loadingView.frame = view.bounds
        }
        loadingView.state = .loading
    }
    
    func stopAnimation(_ state: XLoadingViewState = .success, _ removeFromSuperView: Bool = true) {
        loadingView.state = state
        if removeFromSuperView {
            loadingView.removeFromSuperview()
        }
    }
    
    @objc func goBack() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension XBaseViewController: XLoadingViewDelegate {
    
    func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    func loadingViewDidTapped(_ loadingView: XLoadingView) {
        loadingView.state = .loading
    }
    
    func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return nil
    }
    
    func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "网络连接错误，点击重新加载", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
}