//
//  XQRPermission.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/17.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary

class XQRPermission: NSObject {

    // 相机权限
    class func isCameraPermissionAvailable() -> Bool {
        let authStaus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return authStaus != AVAuthorizationStatus.denied
    }
    
    // 麦克风权限
    class func isMicphonePermissionAvailable() -> Bool {
        let authStaus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        return authStaus != AVAuthorizationStatus.denied
    }
    
    // 相册权限
    class func isPhotoPermissionAvailable() -> Bool {
        return PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.denied
    }
    
}
