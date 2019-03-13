//
//  String+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/07.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    func pinyinString() -> String? {
        let mutableString = NSMutableString(string: self)
        if CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false) &&
            CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false) {
            return NSString(string: mutableString) as String
        }
        
        return nil
    }
}

public extension String {
    public var containEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x3030, 0x00AE, 0x00A9, // Special Characters
            0x1D000...0x1F77F, // Emoticons
            0x2100...0x27BF, // Misc symbols and Dingbats
            0xFE00...0xFE0F, // Variation Selectors
            0x1F900...0x1F9FF: // Supplemental Symbols and Pictographs
                return true
            default:
                continue
            }
        }
        return false
    }
    
    public var hasLetters: Bool {
        return rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
    }
    
    public var hasNumbers: Bool {
        return rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
    }
    
    public var isValidEmail: Bool {
        // http://emailregex.com/
        let regex = "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    public var isValidUrl: Bool {
        return URL(string: self) != nil
    }
    
    public var isValidHttpsUrl: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme == "https"
    }
    
    public var isValidFileUrl: Bool {
        return URL(string: self)?.isFileURL ?? false
    }
    
    func isValidPhone() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^1[0-9]{10}$", options: [.caseInsensitive])
        return regex.firstMatch(in: self, options:[], range: NSMakeRange(0, self.count)) != nil
    }
    
    func containPhone() -> Bool {
        guard let regex = try? NSRegularExpression(pattern: "1[3-9][0-9]{9}", options: [.caseInsensitive]) else {return false}
        let matchNum = regex.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: (self as NSString).length))
        
        return matchNum > 0
    }
    
    func isEmpty() -> Bool {
        let text = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return text == ""
    }
    
    func vaildPassword() -> (bool: Bool, error: String) {
        if self.count < 6 || self.count > 16 {
            return (false,"密码长度应该为6到16位")
        } else if self.contains(" "){
            return (false,"密码不能包含空格")
        } else if self.contains("\t"){
            return (false,"密码不能包含制表符")
        } else if self.contains("\n"){
            return (false,"密码不能包含回车")
        } else{
            return (true,"")
        }
    }
}

/// MARK: MD5
public extension String {
    
//    public func MD5String() -> String {
//        var string = ""
//        let data = self.MD5Data()
//        data.enumerateBytes { (bufferPointer, index, stop) in
//            for i in 0..<index {
//                string += String(format: "%02x", bufferPointer[i])
//            }
//        }
//        return string
//    }
//
//    public func MD5Data() -> Data {
//        let cStr = self.cString(using: String.Encoding.utf8)
//        let resultLength = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: resultLength)
//        CC_MD5(cStr!, CC_LONG(strlen(cStr!)), result)
//        let data = Data(bytes: UnsafePointer<UInt8>(result), count: resultLength)
//        result.deallocate(capacity: resultLength)
//        return data
//    }
    
}

// MARK: Base64
public extension String {
    
    public func base64EncodedString(options: Data.Base64EncodingOptions = []) -> String? {
        let data = self.data(using: .utf8)
        return data?.base64EncodedString(options: options)
    }
    
    public func base64DecodedString(options: Data.Base64DecodingOptions = []) -> String? {
        let base64Data = Data(base64Encoded: self, options: options)
        guard let data = base64Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
}

// MARK: size
public extension String {
    
    func heightWith(font: UIFont, limitWidth: CGFloat, numberOfLines: Int = 0) -> CGFloat {
        let label = UILabel()
        label.font = font
        label.numberOfLines = numberOfLines
        label.text = self
        return label.sizeThatFits(CGSize(width: limitWidth, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    func boundingSize(with size: CGSize, font: UIFont, lineBreakMode: NSLineBreakMode = .byWordWrapping, option: NSStringDrawingOptions = .usesLineFragmentOrigin, context: NSStringDrawingContext? = nil) -> CGSize {
        return boundingRect(with: size, font: font, lineBreakMode: lineBreakMode, option: option, context: context).size
    }
    
    func boundingRect(with size: CGSize, font: UIFont, lineBreakMode: NSLineBreakMode = .byWordWrapping, option: NSStringDrawingOptions = .usesLineFragmentOrigin, context: NSStringDrawingContext? = nil) -> CGRect{
        let text = self as NSString
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode;
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        return text.boundingRect(with: size, options: option, attributes: attributes, context: context)
    }
    
}

/// MARK: URL
public extension String {
    func decodeUrl() -> String {
        let mutStr = NSMutableString(string: self)
        mutStr.replaceOccurrences(of: "+", with: " ", options: NSString.CompareOptions.literal, range: NSMakeRange(0, mutStr.length))
        return mutStr.replacingPercentEscapes(using: String.Encoding.utf8.rawValue) ?? ""
    }
    
    func encodeUrl() -> String? {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
}

/// MARK: Range
public extension String {
    
    func rangesOfString(target: String) -> [NSRange] {
        var ranges = [NSRange]()
        if let expression = try? NSRegularExpression(pattern: target, options: NSRegularExpression.Options(rawValue: 0)) {
            let matches = expression.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, NSString(string: self).length))
            for item in matches {
                ranges.append(item.range)
            }
        }
        return ranges
    }
    
    func rangesOfNumber() -> [NSRange] {
        let regex = try? NSRegularExpression(pattern: "[0-9]+", options: .caseInsensitive)
        let matches = regex?.matches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count))
        return matches?.map({ (match) -> NSRange in
            return match.range
        }) ?? []
    }
    
}

extension String {
    public func float(locale: Locale = .current) -> Float? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self)?.floatValue
    }
    
    public func double(locale: Locale = .current) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self)?.doubleValue
    }
    
    public func cgFloat(locale: Locale = .current) -> CGFloat? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self) as? CGFloat
    }
    
    public func lines() -> [String] {
        var result = [String]()
        enumerateLines { line, _ in
            result.append(line)
        }
        return result
    }
    
    ///        "Swift is amazing".words() -> ["Swift", "is", "amazing"]
    public func words() -> [String] {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let comps = components(separatedBy: chararacterSet)
        return comps.filter { !$0.isEmpty }
    }

    // swiftlint:disable next identifier_name
    /// SwifterSwift: Safely subscript string with index.
    ///
    ///        "Hello World!"[safe: 3] -> "l"
    ///        "Hello World!"[safe: 20] -> nil
    ///
    /// - Parameter i: index.
    public subscript(safe i: Int) -> Character? {
        guard i >= 0 && i < count else { return nil }
        return self[index(startIndex, offsetBy: i)]
    }
    
    /// SwifterSwift: Safely subscript string within a half-open range.
    ///
    ///        "Hello World!"[safe: 6..<11] -> "World"
    ///        "Hello World!"[safe: 21..<110] -> nil
    ///
    /// - Parameter range: Half-open range.
    public subscript(safe range: CountableRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) else { return nil }
        guard let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return String(self[lowerIndex..<upperIndex])
    }
    
    /// SwifterSwift: Safely subscript string within a closed range.
    ///
    ///        "Hello World!"[safe: 6...11] -> "World!"
    ///        "Hello World!"[safe: 21...110] -> nil
    ///
    /// - Parameter range: Closed range.
    public subscript(safe range: ClosedRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) else { return nil }
        guard let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) else { return nil }
        return String(self[lowerIndex..<upperIndex])
    }
    
    public func contains(_ string: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }
}
