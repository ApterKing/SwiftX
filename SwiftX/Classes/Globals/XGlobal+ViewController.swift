//
//  XGlobal+ViewController.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/28.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

/// MARK: 获取某个view所在的UIViewController
public func viewController(for view: UIView) -> UIViewController? {
    var nextResponder = view.next
    while !(nextResponder is UIViewController) {
        nextResponder = nextResponder?.next
    }
    return nextResponder as? UIViewController
}

/// MARK: 获取当前的TabViewController
public var currentTabBarController: UITabBarController? {
//    if let vc = currentViewController {
//        if vc is UINavigationController {
//            return vc as? UINavigationController
//        } else if vc is UITabBarController {
//            return vc as? UITabBarController
//            let currentVC = vc as! UITabBarController
//            let tabVC = currentVC.viewControllers![currentVC.selectedIndex]
//            if tabVC is UINavigationController {
//                return tabVC as? UINavigationController
//            } else {
//                return tabVC.navigationController ?? nil
//            }
//        } else {
//            return vc.navigationController
//        }
//    }
    return nil
}

/// MARK: 获取应用当前最前置的UIViewController
public var currentViewController: UIViewController? {
    var vc = UIApplication.shared.keyWindow?.rootViewController ?? nil
    while vc?.presentedViewController != nil {
        vc = vc?.presentedViewController
        if vc?.presentedViewController == nil {
            if vc is UINavigationController {
                let naviVC = vc as! UINavigationController
                return naviVC.visibleViewController
            } else {
                return vc
            }
        }
    }
    if vc is UITabBarController {
        let currentVC = vc as! UITabBarController
        vc = currentVC.viewControllers![currentVC.selectedIndex]
        if vc is UINavigationController {
            let naviVC = vc as! UINavigationController
            return naviVC.visibleViewController
        }
        return vc
    } else if vc is UINavigationController {
        let currentVC = vc as! UINavigationController
        return currentVC.visibleViewController
    } else {
        return vc
    }
}

/// MARK: 获取应用当前最前置的UINavigationController
public var currentNavigationController: UINavigationController? {
    if let vc = currentViewController {
        if vc is UINavigationController {
            return vc as? UINavigationController
        } else if vc is UITabBarController {
            let currentVC = vc as! UITabBarController
            let tabVC = currentVC.viewControllers![currentVC.selectedIndex]
            if tabVC is UINavigationController {
                return tabVC as? UINavigationController
            } else {
                return tabVC.navigationController ?? nil
            }
        } else {
            return vc.navigationController
        }
    }
    return nil
}
