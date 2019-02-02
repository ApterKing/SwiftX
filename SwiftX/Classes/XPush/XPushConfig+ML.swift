//
//  XPushConfig+ML.swift
//  Swift-X
//
//  Created by wangcong on 2018/11/26.
//

import UIKit

/// MARK: ML拆包配置
extension XPushConfig {
    
    func ml_params() -> [String: Any] {
        return [
            "deployKey": deploymentKey,
            "appVersion": appVersion,
            "buildVersion": buildVersion,
            "deviceId": clientUniqueId,
            "publicKey": publicKey,
            "module": module
        ]
    }
    
    func ml_encode(string: String) -> String? {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlHostAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
    
}
