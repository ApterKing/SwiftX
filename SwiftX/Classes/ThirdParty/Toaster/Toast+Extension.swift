//
//  Toast_Extension.swift
//  MedLinker
//
//  Created by wangcong on 2019/2/27.
//  Copyright © 2019 wangcong. All rights reserved.
//

import UIKit
import Toaster

extension Toast {
    
    class func message (_ text: String?) {
        message(text, duration: 1)
    }
    
    class func message (_ text: String?, duration: TimeInterval) {
        
        guard (text != nil || !text!.isEmptyString()) else { return }
        
        let toast = Toast(text: text)
        toast.view.backgroundColor = UIColor.hex(hex: 0x000000, alpha: 0.5)
        toast.view.textInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        toast.view.font = UIFont.systemFont(ofSize: 13)
        toast.show()
        
        if let current = ToastCenter.default.currentToast {
            if current != toast {
                current.cancel()
                if !current.isFinished {
                    current.isFinished = true
                }
            }
        }
        
        let keyboardVisibleManager = UIKeyboardVisibleManager.share
        // 因为toastView 里面frame是在laysubview的里面修改，外面修改toastViewframe的方法是无效的。  只能通过layer修改
        if keyboardVisibleManager.isVisible {
            let basicAni = CABasicAnimation()
            basicAni.keyPath = "position.y"
            basicAni.fromValue = (201);
            basicAni.toValue = (201); 
            // 不希望核心动画回到原来的位置
            basicAni.fillMode = kCAFillModeForwards;
            basicAni.duration = duration
            basicAni.isRemovedOnCompletion = false;
            toast.view.layer.add(basicAni, forKey: nil)
        }
    }

    static func cancelCurrent() {
        ToastCenter.default.currentToast?.cancel()
    }
}

class UIKeyboardVisibleManager
{
    static let share : UIKeyboardVisibleManager = UIKeyboardVisibleManager()
    fileprivate(set) var isVisible  = false
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        isVisible = true
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        isVisible = false
    }
    
    func setUIKeyboardVisibleConfig() {
        isVisible = false
    }
}

