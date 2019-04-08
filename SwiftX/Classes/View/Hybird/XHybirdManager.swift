//
//  XHybirdManager.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/17.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

let kHybirdCookieChanged = NSNotification.Name(rawValue: "kHybirdCookieChanged")

public class XHybirdManager: NSObject {

    open class func load(urlString: String, injectedHtml: String = "", scrollDelegate: UIScrollViewDelegate? = nil) -> UIViewController? {
        guard let url = URL(string: urlString) else {return nil}
        let hybirdVC = XHybirdViewController()
        hybirdVC.requestURL = url
        return hybirdVC
    }
    
    //通过Html字符串加载页面
    open class func load(html: String, injectedHtml: String = "", scrollDelegate: UIScrollViewDelegate? = nil) -> UIViewController? {
        let hybirdVC = XHybirdViewController()
        //        webViewController.html = injectedHtml
        //        webViewController.injectedHtml = injectedHtml
        //        webViewController.scrollDelegate = scrollDelegate
        return hybirdVC
    }
    
    //更新Cookie
    open class func updateCookie(_ cookie: String) {
        //        WBHybirdManager.shared.sess = cookie
        NotificationCenter.default.post(name: kHybirdCookieChanged, object: nil)
    }
    
    //清理Cookie
    open class func clearCookie (urlString: String) {
        if let url = URL(string: urlString) {
            guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else { return }
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
}
