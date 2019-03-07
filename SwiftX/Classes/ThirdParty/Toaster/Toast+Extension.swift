//
//  Toast_Extension.swift
//  MedLinker
//
//  Created by wangcong on 2019/2/27.
//  Copyright © 2019 wangcong. All rights reserved.
//

import UIKit
import Toaster

public extension Toast {
    
    static public func message (_ text: String?) {
        message(text, duration: 1)
    }
    
    static public func message (_ text: String?, duration: TimeInterval) {
        
        guard (text != nil || !text!.isEmpty()) else { return }
        
        let toast = Toast(text: text)
        toast.view.backgroundColor = UIColor(hexColor: "#000000").withAlphaComponent(0.5)
        toast.view.textInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        toast.view.font = UIFont.systemFont(ofSize: 13)
        toast.view.bottomOffsetPortrait = UIDevice.isIphoneX_xx() ? UIScreen.homeIndicatorMoreHeight + 50 : 50
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
        if keyboardVisibleManager.isVisible {
            let animation = CABasicAnimation()
            animation.keyPath = "position.y"
            animation.fromValue = (201);
            animation.toValue = (201);
            animation.fillMode = CAMediaTimingFillMode.forwards;
            animation.duration = duration
            animation.isRemovedOnCompletion = false;
            toast.view.layer.add(animation, forKey: nil)
        }
    }

    static func cancelCurrent() {
        ToastCenter.default.currentToast?.cancel()
    }
}

class UIKeyboardVisibleManager {
    static let share : UIKeyboardVisibleManager = UIKeyboardVisibleManager()
    fileprivate(set) var isVisible  = false
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
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

