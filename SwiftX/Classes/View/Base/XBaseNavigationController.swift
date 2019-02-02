//
//  XBaseNavigationController.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/16.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

open class XBaseNavigationController: UINavigationController {

    override open func viewDidLoad() {
        super.viewDidLoad()
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "PingFang-SC-Medium", size: 18)!]
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override open var shouldAutorotate: Bool {
        return self.visibleViewController?.shouldAutorotate ?? false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.visibleViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.portrait
    }

    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.visibleViewController?.preferredInterfaceOrientationForPresentation ?? UIInterfaceOrientation.portrait
    }

}
