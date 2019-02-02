//
//  XPushViewController.swift
//  Pods-MedCRM
//
//  Created by wangcong on 2018/11/27.
//

import UIKit
import Swift_X

class XPushViewController: XBaseViewController, UIGestureRecognizerDelegate {
    
    fileprivate(set) var moduleName = ""
    fileprivate(set) var params: [String : Any]?
    private var loadingView: UIView {
        get {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
            let label = UILabel(frame: CGRect(x: 0, y: (UIScreen.height - 24) / 2.0, width: UIScreen.width, height: 24))
            label.text = "加载中..."
            label.textAlignment = .center
            label.textColor = MLTheme.color.gray
            label.font = MLTheme.font.pingFangSCMedium(size: 18)
            view.addSubview(label)
            return view
        }
    }
    fileprivate(set) var bridge: RCTBridge?
    private var rootView: RCTRootView?
    fileprivate(set) var detectedBridge: RCTBridge?
    fileprivate(set) var detectedView: RCTRootView?
    
    private var isAllowsBackForwardNavigationGestures  = false
    
    var statusStyle: Int = 1 {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    class func register(deployKey: String, resourcesBundle: String) {
        #if DEBUG
        XPushManager.register(serverUrl: "http://pm.qa.medlinker.com/api",
                               deploymentKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoibWVkLXJuLWlvcyIsImVudiI6ImRldmVsb3BtZW50IiwiaWF0IjoxNTMwNjk3MzAyfQ.43XEuT6zm8l9OSiwGoPzDYNl6ULHzBgwCs5U9yNo6r0",
                               bundleResource: "main.jsbundle")
        #else
        XPushManager.register(serverUrl: "https://pm.medlinker.com/api",
                               deploymentKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoibWVkLXJuLWlvcyIsImVudiI6InByb2R1Y3Rpb24iLCJpYXQiOjE1MzA2OTczMDJ9.JTtq93c1a-ysiS_kUCZhuvgtRK0_rVJkIvn_968LJPI",
                               bundleResource: "main.jsbundle")
        #endif
    }
    
    init(moduleName: String,
         params: [String : Any]?,
         loadingView: UIView? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.moduleName = moduleName
        self.params = params
        
        openRootView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        detectedBridge?.invalidate()
        detectedView?.contentViewInvalidated()
        detectedView = nil
        
        //        bridge?.invalidate()
        //        rootView?.contentViewInvalidated()
        rootView = nil
        //        bridge = nil
        //        XPushManager.preloadBridge()
    }
    
    override func loadView() {
        super.loadView()
        
        // 小模块预加载快于页面view创建
        if rootView != nil && view != rootView {
            XPushManager.addRollbackIfNeeded(for: moduleName)
            view = rootView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        navigationController?.navigationBar.isHidden = true
        
        XPushLog("XPushManager ------- openRootView   ----- end  --  1")
        
        XPushManager.ml_updateIfNeeded(moduleName) { [weak self] (shouldReloads) in
            guard let baseShouldReload = shouldReloads?.contains("Base"), let weakSelf = self else { return }
            
            // 这里需要检测一下Base包是否存在错误
            if baseShouldReload {
                weakSelf.detectedBridge = XPushManager.bridge(for: "Base")
                weakSelf.detectedView = RCTRootView(bridge: weakSelf.detectedBridge!, moduleName: "Base", initialProperties: nil)
                XPushManager.addRollbackIfNeeded(for: "Base")
                weakSelf.view.insertReactSubview(weakSelf.detectedView, at: 0)
                XPushLog("XPushManager ------- openRootView   ----- detected")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 系统会重置delegate，需要每次进入延时设置；allowsBackForwardNavigationGestures处理同理
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.rt_navigationController?.interactivePopGestureRecognizer?.delegate = weakSelf
        }
    }
    
    @objc open func openRootView() {
        XPushLog("XPushManager ------- openRootView   ----- start")
        bridge = XPushManager.preloadedBridge
        guard let url = XPushManager.bridgeBundleURL(for: moduleName) else { return }
        bridge?.enqueueApplicationModule(moduleName, at: url, onSourceLoad: { [weak self] (error, source) in
            guard let weakSelf = self, error == nil else { return }
            weakSelf.rootView = RCTRootView(bridge: weakSelf.bridge, moduleName: weakSelf.moduleName, initialProperties: RCTRootView.initialProperties(params: weakSelf.params))
            weakSelf.rootView?.setRuningJSView(weakSelf.loadingView)
            if weakSelf.isViewLoaded {  // 大模块第一次加载慢于view创建
                XPushManager.addRollbackIfNeeded(for: weakSelf.moduleName)
                weakSelf.view = weakSelf.rootView
            }
            XPushLog("XPushManager ------- openRootView   ----- end")
        })
    }
    
    // 返回
    @objc func goBack() {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.navigationController?.interactivePopGestureRecognizer?.delegate = weakSelf
        }
    }
    
    // MARK: vc需要支持的属性
    //导航栏的颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return statusStyle==1 ? .default : .lightContent
        }
    }
    
    //手势
    func allowsBackForwardNavigationGestures(_ isAllow: Bool) {
        isAllowsBackForwardNavigationGestures = isAllow
        rt_navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    //设置手势代理
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return isAllowsBackForwardNavigationGestures
    }
}
