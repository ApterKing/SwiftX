//
//  XHybirdViewController.swift
//  SwiftX
//
//  Created by wangcong on 2018/10/29.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit
import WebKit

open class XHybirdViewController: XBaseViewController {
    
    var requestURL: URL?
    let hybirdView = XHybirdView()
    var isProgressHidden = false {
        didSet {
            progressView.isHidden = isProgressHidden
        }
    }
    
    internal var backButton = UIButton()
    internal var closeButton = UIButton()
    private lazy var progressView: UIProgressView = {
        let progressV = UIProgressView()
        progressV.progressViewStyle = .bar
        progressV.progressTintColor = UIColor.orange
        progressV.trackTintColor = UIColor.clear
        return progressV
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    override open func viewDidLayoutSubviews() {
        hybirdView.frame = view.bounds
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension XHybirdViewController {
    private func _initUI() {
        title = ""
    
        backButton.frame = CGRect(x: 0, y: 0, width: 35, height: 44)
        backButton.addTarget(self, action: #selector(_goBack), for: .touchUpInside)
        backButton.contentHorizontalAlignment = .left
        if let backImagePath = Bundle.main.path(forResource: String(format: "icon_nav_back_gray@%.0fx", UIScreen.main.scale), ofType: "png") {
            backButton.setImage(UIImage(contentsOfFile: backImagePath), for: .normal)
        }
        
        closeButton.frame = CGRect(x: 38, y: 0, width: 35, height: 44)
        closeButton.addTarget(self, action: #selector(_close), for: .touchUpInside)
        closeButton.contentHorizontalAlignment = .left
        if let backImagePath = Bundle.main.path(forResource: String(format: "icon_nav_close_gray@%.0fx", UIScreen.main.scale), ofType: "png") {
            closeButton.setImage(UIImage(contentsOfFile: backImagePath), for: .normal)
        }
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton), UIBarButtonItem(customView: closeButton)]
        
        hybirdView.delegate = self
        view.addSubview(hybirdView)
        
        progressView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 2)
        view.addSubview(progressView)
        
        if let url = requestURL {
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadRevalidatingCacheData, timeoutInterval: 20)
            let _ = hybirdView.loadRequest(request)
        }
    }
    
    @objc private func _goBack() {
        if hybirdView.canGoBack {
            hybirdView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func _close() {
        navigationController?.popViewController(animated: true)
    }
}

extension XHybirdViewController: XHybirdViewDelegate {
    
    func hybirdView(_ hybirdView: XHybirdView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return true
    }
    
    func hybirdViewDidStartLoad(_ hybirdView: XHybirdView) {
        
    }

    func hybirdView(_ hybirdView: XHybirdView, progressChanged progress: Float) {
        progressView.alpha = 1.0
        progressView.setProgress(progress, animated: true)
        if progress  >= 1.0 {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                self.progressView.alpha = 0
            }, completion: { (finish) in
                self.progressView.setProgress(0.0, animated: false)
            })
        }
    }
    
    func hybirdViewDidFinishLoad(_ hybirdView: XHybirdView) {
        title = hybirdView.webView.title
    }
    
    func hybirdView(_ hybirdView: XHybirdView, didFailLoadWithError error: Error) {
        
    }
    
}


