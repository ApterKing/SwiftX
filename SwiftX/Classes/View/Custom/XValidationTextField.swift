//
//  XValidationTextField.swift
//  SwiftX
//
//  Created by wangcong on 2019/3/30.
//

import UIKit

@objc public protocol XValidationTextFieldDelegate {
    
    // 将要开始输入
    @objc optional func validationTextFieldWillBeginInput(_ textField: XValidationTextField)

    // 已经输入
    @objc optional func validationTextFieldDidInput(_ textField: XValidationTextField, changed text: String)
    
    // 删除
    @objc optional func validationTextFieldDidDelete(_ textField: XValidationTextField, changed text: String)
    
    // 完成输入（输入的字符达到了指定长度）
    @objc optional func validationTextFieldDidFinishInput(_ textField: XValidationTextField)
}

public class XValidationTextField: UIView, UIKeyInput, UITextInputTraits {
    
    private var _length: Int = 6
    public var length: Int {
        get {
            return _length
        }
        set {
            _length = newValue
            self.setNeedsDisplay()
        }
    }
    private var _text: String = ""
    public var text: String {
        get {
            return _text
        }
        set {
            _text = newValue
            self.setNeedsDisplay()
        }
    }
    public var delegate: XValidationTextFieldDelegate?
    public var textColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    public var font: UIFont = UIFont.systemFont(ofSize: 30) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var lineColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    public var lineHighlightedColor: UIColor = UIColor(hexColor: "66B30C") {
        didSet {
            setNeedsDisplay()
        }
    }
    public var itemSpacing: CGFloat = 15 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }

    public override func becomeFirstResponder() -> Bool {
        delegate?.validationTextFieldWillBeginInput?(self)
        return super.becomeFirstResponder()
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isFirstResponder {
            _ = self.becomeFirstResponder()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let eachWidth = width / CGFloat(_length)
        let eachHeight = height - 1
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1)
        context?.setLineCap(.round)
        context?.setStrokeColor(lineColor.cgColor)
        context?.setFillColor(lineColor.cgColor)
        
        // 绘制横线
        for index in 0 ..< _length {
            let highlightedIndex = _text.count != _length ? _text.count : _text.count - 1
            if index == highlightedIndex {
                context?.saveGState()
                context?.setLineWidth(2)
                context?.setStrokeColor(lineHighlightedColor.cgColor)
                context?.setFillColor(lineHighlightedColor.cgColor)
                context?.move(to: CGPoint(x: CGFloat(index) * eachWidth, y: eachHeight))
                context?.addLine(to: CGPoint(x: CGFloat(index) * eachWidth + (eachWidth - itemSpacing), y: eachHeight))
                context?.drawPath(using: .fillStroke)
                context?.restoreGState()
            } else {
                context?.move(to: CGPoint(x: CGFloat(index) * eachWidth, y: eachHeight))
                context?.addLine(to: CGPoint(x: CGFloat(index) * eachWidth + (eachWidth - itemSpacing), y: eachHeight))
                context?.drawPath(using: .fillStroke)
            }
        }

        // 绘制文字
        for (index, c) in _text.enumerated() {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let attributes = [
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.paragraphStyle: style
            ]
            (String(c) as NSString).draw(in: CGRect(x: CGFloat(index) * eachWidth, y: 0, width: eachWidth - itemSpacing, height: eachHeight), withAttributes: attributes)
        }

    }
    
    /// MARK: UIKeyInput
    public var hasText: Bool {
        return _text.count > 0
    }
    
    public func insertText(_ text: String) {
        if _text.count < _length {
            let numbers = "0123456789"
            let cs: CharacterSet = CharacterSet(charactersIn: numbers).inverted
            let filtered = text.components(separatedBy: cs).joined(separator: "")
            if text == filtered {
                _text.append(text)
                
                delegate?.validationTextFieldDidInput?(self, changed: text)
                if _text.count == _length {
                    delegate?.validationTextFieldDidFinishInput?(self)
                }
                
                setNeedsDisplay()
            }
        }
    }
    
    public func deleteBackward() {
        if _text.count > 0 {
            let changed = _text.remove(at: _text.index(before: _text.endIndex))
            delegate?.validationTextFieldDidDelete?(self, changed: String(changed))
            
            setNeedsDisplay()
        }
    }
    
    /// MARK: UITextInputTraits
    public var keyboardType: UIKeyboardType = .numberPad
}

extension XValidationTextField {
    
    private func _init() {
        backgroundColor = UIColor.clear
    }
    
}

extension XValidationTextField {
    
    public func clear() {
        text = ""
    }
    
}
