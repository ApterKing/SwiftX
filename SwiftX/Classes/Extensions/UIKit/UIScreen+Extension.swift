//
//  UIScreen+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/07.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

public extension UIScreen {
    
    public class var size: CGSize {
        return UIScreen.main.bounds.size
    }
    
    public class var width: CGFloat {
        return size.width
    }
    
    public class var height: CGFloat {
        return size.height
    }
    
    public class var statusBarHeight: CGFloat {
        get {
            return UIDevice.isIphoneX() ? 44 : 20
        }
    }
    
    public class var navigationBarHeight:CGFloat {
        get {
            return UIDevice.isIphoneX() ? 88 : 64
        }
    }
    
    public class var tabBarHeight:CGFloat {
        get {
            return UIDevice.isIphoneX() ? 83 : 49
        }
    }
    
    public class var homeIndicatorMoreHeight:CGFloat {
        get {
            return UIDevice.isIphoneX() ? 34 : 0
        }
    }
    
    public class var statusBarMoreHeight:CGFloat {
        get {
            return UIDevice.isIphoneX() ? 24 : 0
        }
    }
}
