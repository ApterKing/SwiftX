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

/// 获取最顶层的viewController
public var topViewController: UIViewController? {
    let windows = UIApplication.shared.windows
    var rootViewController: UIViewController?
    for window in windows {
        if let windowRootViewController = window.rootViewController {
            rootViewController = windowRootViewController
            break
        }
    }
    return top(of: rootViewController)
}

/// 获取keyWindow最顶层的viewController
public var topKeyWindowViewController: UIViewController? {
    return top(of: UIApplication.shared.keyWindow?.rootViewController)
}

/// 获取当前的navigationController
public var topNavigationController: UINavigationController? {
    let viewController = topViewController
    return topNavi(of: viewController)
}

/// 获取keyWindow最顶层的navigationController
public var topKeyWindowNavigationController: UINavigationController? {
    let viewController = topKeyWindowViewController
    return topNavi(of: viewController)
}

/// 获取与某个viewController相关联的最顶层viewController
private func top(of viewController: UIViewController?) -> UIViewController? {

    if let presentedViewController = viewController?.presentedViewController {
        return top(of: presentedViewController)
    }

    if let tabBarController = viewController as? UITabBarController {
        let selectedViewController = tabBarController.selectedViewController
        return top(of: selectedViewController)
    }

    if let navigationController = viewController as? UINavigationController,
        let visibleViewController = navigationController.visibleViewController {
        return top(of: visibleViewController)
    }

    if let pageController = viewController as? UIPageViewController,
        pageController.viewControllers?.count == 1 {
        return top(of: pageController.viewControllers?.first)
    }

    for subview in viewController?.view.subviews ?? [] {
        if let childViewController = subview.next as? UIViewController {
            return top(of: childViewController)
        }
    }

    return viewController
}

/// 获取与某个指定viewController关联的navigationController
private func topNavi(of viewController: UIViewController?) -> UINavigationController? {
    if let navigationController = viewController as? UINavigationController {
        return navigationController
    }

    if let tabbarController = viewController as? UITabBarController {
        let selectedViewController = tabbarController.selectedViewController
        if let navigationController = selectedViewController as? UINavigationController {
            return navigationController
        } else {
            return tabbarController.navigationController
        }
    }

    return viewController?.navigationController
}
