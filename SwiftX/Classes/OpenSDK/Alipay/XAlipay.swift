//
//  XAlipay.swift
//  SwiftX
//
//  Created by wangcong on 2019/3/5.
//

final public class XAlipay: NSObject {
    
    public static let `default` = XAlipay()
    private override init() {}
    
    public func handleOpen(url: URL) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService()?.processOrder(withPaymentResult: url, standbyCallback: { (result) in
                print("XAlipay  handleOpen  ----   \(result)")
            })
            return true
        }
        return false
    }
    
    /// MARK: 支付
    public typealias PayHandler = ((Error?) -> Void)
    private var payHandler: PayHandler?
    
}

// 支付
extension XAlipay {
    
    public func pay(with orderString: String, scheme: String, payHandler: PayHandler? = nil) {
        self.payHandler = payHandler
        AlipaySDK.defaultService()?.payOrder(orderString, fromScheme: scheme, callback: { (result) in
            print("XAlipay  pay  ----   \(result)")
            guard let status = result?["resultStatus"] as? String else { return }
            let memo = result?["memo"] as? String
            if status == "9000" {  // 支付成功
                
            }
        })
    }
    
}
