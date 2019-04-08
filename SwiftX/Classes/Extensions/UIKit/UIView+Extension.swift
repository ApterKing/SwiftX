//
//  UIView+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/11.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

// MARK: viewController
public extension UIView {
    var viewController: UIViewController? {
        get {
            var nextResponder = self.next
            while !(nextResponder is UIViewController) {
                nextResponder = nextResponder?.next
            }
            return nextResponder as? UIViewController
        }
    }
}

// MARK: Frame
public extension UIView {
    
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            var rect = frame
            rect.origin.x = newValue - rect.size.width
            frame = rect
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            var rect = frame
            rect.origin.y = newValue - frame.size.height
            frame = rect
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center = CGPoint(x: newValue, y: center.y)
        }
    }
    
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center = CGPoint(x: center.x, y: newValue)
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            var rect = frame
            rect.origin = newValue
            frame = rect
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            var rect = frame
            rect.size = newValue
            frame = rect
        }
    }
}

// MARK: Round，当View的frame确定后有效
public extension UIView {
    
    public func round(byRoundingCorners: UIRectCorner = .allCorners, cornerRadi: CGFloat) {
        self.round(byRoundingCorners: byRoundingCorners, cornerRadii: CGSize(width: cornerRadi, height: cornerRadi))
    }
    
    public func round(byRoundingCorners: UIRectCorner = .allCorners, cornerRadii: CGSize) {
        guard let maskLayer = self.layer.mask else {
            let rect = self.bounds
            let bezierPath = UIBezierPath(roundedRect: rect,
                                          byRoundingCorners: byRoundingCorners,
                                          cornerRadii: cornerRadii)
            defer {
                bezierPath.close()
            }
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = bounds
            shapeLayer.path = bezierPath.cgPath
            self.layer.mask = shapeLayer
            return
        }
    }
}

// MARK: UIView 快照
public extension UIView {
    
    public var snapshotImage: UIImage? {
        return snapshot()
    }
    
    public func snapshot(rect: CGRect = CGRect.zero, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        var snapRect = rect
        if __CGSizeEqualToSize(rect.size, CGSize.zero) {
            snapRect = calculateSnapshotRect()
        }
        UIGraphicsBeginImageContextWithOptions(snapRect.size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        self.drawHierarchy(in: snapRect, afterScreenUpdates: false)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // 计算UIView所显示内容Rect
    func calculateSnapshotRect() -> CGRect {
        var targetRect = self.bounds
        if let scrollView = self as? UIScrollView {
            let contentInset = scrollView.contentInset
            let contentSize = scrollView.contentSize
            
            targetRect.origin.x = contentInset.left
            targetRect.origin.y = contentInset.top
            targetRect.size.width = targetRect.size.width  - contentInset.left - contentInset.right > contentSize.width ? targetRect.size.width  - contentInset.left - contentInset.right : contentSize.width
            targetRect.size.height = targetRect.size.height - contentInset.top - contentInset.bottom > contentSize.height ? targetRect.size.height  - contentInset.top - contentInset.bottom : contentSize.height
        }
        return targetRect
    }
    
}
