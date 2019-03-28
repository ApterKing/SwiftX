//
//  XBMKMapManager.swift
//  SwiftX
//
//  Created by wangcong on 2019/3/9.
//

final public class XBMKMapManager: NSObject {
    
    static public let `default` = XBMKMapManager()
    private override init() {}
    private lazy var mapManager = BMKMapManager()
    
    public func start(_ appkey: String) {
        mapManager.start(appkey, generalDelegate: self)
    }
    
}

extension XBMKMapManager: BMKGeneralDelegate {
    
    public func onGetNetworkState(_ iError: Int32) {
        #if DEBUG
        NSLog("com.SwiftX.OpenSDK.Baidu.Map.onGetNetworkState    onGetPermissionState   \(iError)")
        #endif
    }
    
    public func onGetPermissionState(_ iError: Int32) {
        #if DEBUG
        NSLog("com.SwiftX.OpenSDK.Baidu.Map.XBMKMapManager    onGetPermissionState   \(iError)")
        #endif
    }
    
}


