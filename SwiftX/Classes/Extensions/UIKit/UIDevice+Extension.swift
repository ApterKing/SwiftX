//
//  UIDevice+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/17.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

public extension UIDevice {

    public class var isIphone: Bool {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
    }

    public class var iphone_568: Bool {
        return isIphone && max(UIScreen.width, UIScreen.height) == 568.0
    }

    public class var iphone_568_or_less: Bool {
        return isIphone && max(UIScreen.width, UIScreen.height) <= 568.0
    }

    public class var iphone_667: Bool {
        return isIphone && max(UIScreen.width, UIScreen.height) == 667.0
    }

    public class var iphone_667_or_less: Bool {
        return isIphone && max(UIScreen.width, UIScreen.height) <= 667.0
    }

    public class var iphone_736: Bool {
        return isIphone && max(UIScreen.width, UIScreen.height) == 736.0
    }

    public class var iphone_736_or_less: Bool {
        return isIphone && max(UIScreen.width, UIScreen.height) <= 736.0
    }

    public class func isIpone4_5() -> Bool {
        return UIScreen.width == 320 ? true : false
    }
    
    public class func isIpone6_7() -> Bool {
        return UIScreen.width == 375 ? true : false
    }
    
    public class func isIpone6_7_Plus() -> Bool {
        return UIScreen.width == 414 ? true : false
    }
    
    public class func isIphoneX_xx() -> Bool {
        let height = UIScreen.main.bounds.size.height
        return height == 812 || height <= 896 && UIScreen.main.scale == 2.0 || height <= 896 && UIScreen.main.scale == 3.0
    }
    
    public class var orientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }

    public var isSimulator: Bool {
        get {
            var isSim = false
            #if arch(i386) || arch(x86_64)
            isSim = true
            #endif
            return isSim
        }
    }
    
    public var isJailbroken: Bool {
        get {
            if isSimulator {
                return false
            }
            
            let paths = [
                "/Applications/Cydia.app",
                "/private/var/lib/apt/",
                "/private/var/lib/cydia",
                "/private/var/stash"
            ]
            
            for path in paths {
                if FileManager.default.fileExists(atPath: path) {
                    return true
                }
            }
            
            let uuid = CFUUIDCreate(nil)
            let string = CFUUIDCreateString(nil, uuid)
            let path = "/private/\(String(describing: string))"
            do {
                try "test".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                try FileManager.default.removeItem(atPath: path)
                return true
            }
            catch {
                return false
            }
        }
    }
}
