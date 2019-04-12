//
//  XHybirdView.swift
//  SwiftX
//
//  Created by wangcong on 2018/10/28.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit
import WebKit

// 自定义webView代理
@objc public protocol XHybirdViewDelegate {
    
    @objc optional func hybirdView(_ hybirdView: XHybirdView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool
    
    @objc optional func hybirdViewDidStartLoad(_ hybirdView: XHybirdView)
    
    @objc optional func hybirdView(_ hybirdView: XHybirdView, progressChanged progress: Float)
    
    @objc optional func hybirdViewDidFinishLoad(_ hybirdView: XHybirdView)
    
    @objc optional func hybirdView(_ hybirdView: XHybirdView, didFailLoadWithError error: Error)
    
}

open class XLocalstorageManager {
    static var sharePreferences = WKPreferences()
    static var shareProcessPool = WKProcessPool()
}

// 通过WKWebView实现，提供了进度加载进度条，headerView，footerView
open class XHybirdView: UIView {
    
    private var wkContentView: UIView!
    private var latestScrollViewContentSize = CGSize.zero
    private lazy var wkWebView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        configuration.preferences = XLocalstorageManager.sharePreferences
//        configuration.preferences.minimumFontSize = 17
//        configuration.preferences.javaScriptEnabled = true
        configuration.processPool = XLocalstorageManager.shareProcessPool
        configuration.userContentController = userContentController
        
        //        let cookieValue = String(format:"document.cookie ='platform=%@;path=/;domain=medlinker.com;expires=Sat, 02 May 2019 23:38:25 GMT；';document.cookie = 'sess=%@;path=/;domain=medlinker.com;expires=Sat, 02 May 2018 23:38:25 GMT；';",MLHybrid.shared.platform,MLHybrid.shared.sess)
        let cookieValue = ""
        let cookieScript = WKUserScript(source: cookieValue, injectionTime: .atDocumentStart , forMainFrameOnly: false)
        userContentController.addUserScript(cookieScript)
        configuration.userContentController = userContentController
        
        let  webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    // 为hybirdView添加头部视图
    open var hybirdHeaderView: UIView? {
        didSet {
            if let headerView = hybirdHeaderView {
                if let view = scrollView.viewWithTag(Int.max) {
                    view.removeFromSuperview()
                }
                headerView.tag = Int.max
                
                hybirdFooterView = UIView(frame: CGRect(x: 0, y: 0, width: headerView.width, height: headerView.height))
            }
        }
    }
    
    // 为hybirdView添加尾部视图
    open var hybirdFooterView: UIView? {
        didSet {
            if let footerView = hybirdFooterView {
                if let view = scrollView.viewWithTag(Int.max) {
                    view.removeFromSuperview()
                }
                footerView.tag = Int.max - 1
            }
        }
    }
    
    open var delegate: XHybirdViewDelegate? {
        didSet {
            wkWebView.navigationDelegate = self
        }
    }
    open var request: URLRequest?
    open var scrollView: UIScrollView {
        get {
            return wkWebView.scrollView
        }
    }
    
    open var canGoBack: Bool {
        get {
            return wkWebView.canGoBack
        }
    }
    
    open var canGoForward: Bool {
        get {
            return wkWebView.canGoForward
        }
    }
    
    open var webView: WKWebView {
        get {
            return wkWebView
        }
    }
    
    open func loadRequest(_ request: URLRequest) -> WKNavigation? {
        return wkWebView.load(request)
    }
    
    open func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        return wkWebView.loadHTMLString(string, baseURL: baseURL)
    }
    
    open func reload() {
        wkWebView.reload()
    }
    
    open func stopLoading() {
        wkWebView.stopLoading()
    }
    
    open func goBack() {
        wkWebView.goBack()
    }
    
    open func goForward() {
        wkWebView.goForward()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(wkWebView)
        wkContentView = wkWebView.scrollView.subviews[0]
        
        wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        wkWebView.frame = bounds
        
        if let headerView = hybirdHeaderView, headerView.superview == nil {
            scrollView.addSubview(headerView)
            
            var frame = wkContentView.frame
            frame.origin.y = hybirdHeaderView?.bounds.size.height ?? 0
            wkContentView.frame = frame
            scrollView.contentSize = CGSize(width: frame.size.width, height: wkContentView.top + wkContentView.height + 800)
            headerView.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        }
    }
    
    deinit {
        hybirdHeaderView?.removeObserver(self, forKeyPath: "frame")
        scrollView.removeObserver(self, forKeyPath: "contentSize")
        wkWebView.removeObserver(self, forKeyPath: "estimatedProgress")
        wkWebView.navigationDelegate = nil
    }
}

/// MARK: Observer
extension XHybirdView {
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            delegate?.hybirdView?(self, progressChanged: Float(wkWebView.estimatedProgress))
        } else if keyPath == "contentSize" {
//            if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize, newSize.height != latestScrollViewContentSize.height {
//                latestScrollViewContentSize = newSize
//                scrollView.removeObserver(self, forKeyPath: "contentSize")
//                scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: wkContentView.y + wkContentView.height)
//                scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
//            }
        } else if keyPath == "frame" {
//            _resetAllFrame()
        }
    }
    
    private func _resetAllFrame() {
        if let headerView = hybirdHeaderView, headerView.superview != nil {
            var frame = wkContentView.frame
            frame.origin.y = hybirdHeaderView?.bounds.size.height ?? 0
            wkContentView.frame = frame
            scrollView.contentSize = CGSize(width: frame.size.width, height: wkContentView.top + wkContentView.height + 800)
        }
        
        if let footerView = hybirdFooterView, footerView.superview != nil {
            var frame = footerView.frame
            frame.origin.y = wkContentView.frame.origin.y + wkContentView.frame.size.height
            scrollView.contentSize = CGSize(width: frame.size.width, height: wkContentView.top + wkContentView.height)
        }
    }
}

extension XHybirdView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let navigationType = navigationAction.navigationType.rawValue
        let isRequest = delegate?.hybirdView?(self, shouldStartLoadWith: navigationAction.request, navigationType: UIWebView.NavigationType(rawValue: navigationType) ?? .other) ?? true
        NSLog("webView   dicidePolicyFor   ---   \(String(describing: navigationAction.request.url))")
        if isRequest {
            request = navigationAction.request
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate?.hybirdViewDidStartLoad?(self)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let response = navigationResponse.response as? HTTPURLResponse, let url = URL(string: "www.miinecon.com"), let headers = response.allHeaderFields as? [String: String] {
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
            print("获取到cookie： \(cookies)    \(url)")
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let footerView = hybirdFooterView, footerView.superview == nil {
            scrollView.addSubview(footerView)
            
            var frame = footerView.frame
            frame.origin.y = wkContentView.top + wkContentView.height
            footerView.frame = frame
            scrollView.contentSize = CGSize(width: frame.size.width, height: footerView.top + footerView.height)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.hybirdViewDidFinishLoad?(self)
        
        if #available(iOS 11.0, *) {
            let store = webView.configuration.websiteDataStore.httpCookieStore
            store.getAllCookies { (cookies) in
                for cookie in cookies {
                    if cookie.name == "__u_mall_id" {
                        let savedUserId = UserDefaults.standard.string(forKey: "currentUserId")
                        UserDefaults.standard.setValue(cookie.value, forKey: "currentUserId")
                        if savedUserId != cookie.value {
//                            HTTPCookieStorage.shared.setCookies(cookies, for: kHybird_Cookie_URL, mainDocumentURL: nil)
//                            NotificationCenter.default.post(name: WBUserEntity.userStatusChangedNotification, object: nil)
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.hybirdView?(self, didFailLoadWithError: error)
    }
    
}



