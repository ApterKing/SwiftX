//
//  XTextView.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/27.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

open class XTextView: UITextView {

    private lazy var placeholderLabel: UILabel = {
        $0.textColor = UIColor.lightGray
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textAlignment = .left
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    public var placeholder: String? {
        get {
            return self.placeholderLabel.text
        }
        set {
            self.placeholderLabel.text = newValue
            if let text = newValue {
                let size = text.boundingSize(with: bounds.size, font: placeholderLabel.font, lineBreakMode: .byTruncatingTail, option: .usesLineFragmentOrigin, context: nil)
                self.placeholderLabel.frame = CGRect(origin: self.placeholderLabel.frame.origin, size: size)
            }
        }
    }

    public var placeholderColor: UIColor {
        get {
            return self.placeholderLabel.textColor
        }
        set {
            self.placeholderLabel.textColor = newValue
        }
    }

    public var placeholserFont: UIFont {
        get {
            return self.placeholderLabel.font
        }
        set {
            self.placeholderLabel.font = newValue
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    public convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if let text = placeholder {
            let size = text.boundingSize(with: bounds.size, font: placeholderLabel.font, lineBreakMode: .byTruncatingTail, option: .usesLineFragmentOrigin, context: nil)
            self.placeholderLabel.frame = CGRect(origin: CGPoint(x: 5, y: 7), size: size)
        }
    }

    private func setupView() {
        self.addSubview(placeholderLabel)

        NotificationCenter.default.addObserver(self, selector: #selector(textChanged(notification:)), name: UITextView.textDidChangeNotification, object: nil)
    }

    @objc private func textChanged(notification: NSNotification) {
        guard let placeholder = self.placeholder else {
            return
        }
        if placeholder.lengthOfBytes(using: .utf8) == 0 {
            return
        }

        self.placeholderLabel.alpha = self.text.lengthOfBytes(using: .utf8) == 0 ? 1 : 0
    }

}
