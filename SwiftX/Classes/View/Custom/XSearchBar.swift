//
//  XSearchBar.swift
//  SwiftX
//
//  Created by wangcong on 2019/2/24.
//

import UIKit

public class XSearchBar: UISearchBar {
    
    public var searchField: UITextField?
    public var searchPlaceHolderLabel: UILabel?
    public var cancelButton: UIButton?
    
    public var editable: Bool = true {
        didSet {
            searchField?.isEnabled = editable
        }
    }
    
    public var placeholderColor: UIColor =  UIColor(hexColor: "#999999").withAlphaComponent(0.8) {
        didSet {
            searchPlaceHolderLabel?.textColor = placeholderColor
        }
    }

    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
        tintColor = UIColor(hexColor: "#999999")
        
        _initSearchFeildIfNeeded()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        _initSearchFeildIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension XSearchBar {
    
    private func _initSearchFeildIfNeeded() {
        guard searchField == nil else { return }
        
        // 取消按钮
        cancelButton = value(forKey: "_cancelButton") as? UIButton
        cancelButton?.setTitle("取消", for: .normal)
        cancelButton?.setTitleColor(UIColor(hexColor: "#66B30C"), for: .normal)
        cancelButton?.setTitleColor(UIColor(hexColor: "#66B30C").withAlphaComponent(0.8), for: .highlighted)
        
        // 搜索输入框
        searchField = value(forKey: "_searchField") as? UITextField
        searchField?.textColor = UIColor(hexColor: "#999999")
        searchField?.backgroundColor = UIColor(hexColor: "#f6f6f6")
        searchField?.isEnabled = editable
        
        let leftImageView = UIImageView(image: UIImage(named: "icon_search", in: Bundle(for: self.classForCoder), compatibleWith: nil))
        leftImageView.contentMode = .scaleAspectFill
        leftImageView.frame = searchField?.leftView?.bounds ?? CGRect(x: 3, y: 0, width: 18, height: 18)
        searchField?.leftView = leftImageView
        
        // 提示
        searchPlaceHolderLabel = searchField?.value(forKey: "_placeholderLabel") as? UILabel
        searchPlaceHolderLabel?.textColor = placeholderColor
    }
    
}
