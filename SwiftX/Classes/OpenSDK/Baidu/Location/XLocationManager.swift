//
//  XLocationManager.swift
//  SnapKit
//
//  Created by wangcong on 2019/3/7.
//

final public class XLocationManager: NSObject {
    
    public typealias CompletionHandler = ((_ info: LocationInfo?, _ error: Error?) -> Void)

    static public let `default` = XLocationManager()
    public var locationInfo: LocationInfo?
    private override init() {}
    private lazy var locationManager: BMKLocationManager = {
        let manager = BMKLocationManager()
        manager.coordinateType = BMKLocationCoordinateType.BMK09LL
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    public func checkPermision(_ appKey: String) {
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: appKey, authDelegate: self)
    }
    
    public func startUpdatingLocation(_ complection: CompletionHandler? = nil) {
        locationManager.requestLocation(withReGeocode: true, withNetworkState: true) { (location, state, error) in
            if let location = location {
                self.locationInfo = LocationInfo(location)
                complection?(LocationInfo(location), nil)
            } else {
                complection?(nil, error)
            }
        }
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

}

extension XLocationManager: BMKLocationAuthDelegate {
    
    public func onCheckPermissionState(_ iError: BMKLocationAuthErrorCode) {
        NSLog("OpenSDK.Location.bmkLocationManager  onCheckPermissionState   \(iError == BMKLocationAuthErrorCode.success)")
        startUpdatingLocation { (info, error) in
        }
    }
    
}

extension XLocationManager {
    
    public class LocationInfo: NSObject {
        public var location: CLLocation?
        public var locationID: String?
        
        public var country: String?
        public var countryCode: String?
        public var province: String?
        public var city: String?
        public var cityCode: String?
        public var district: String?
        public var street: String?
        public var streetNumber: String?
        
        ///行政区划编码属性
        public var adCode: String?

        fileprivate convenience init(_ bmkLocation: BMKLocation) {
            self.init()
            location = bmkLocation.location
            locationID = bmkLocation.locationID
            
            country = bmkLocation.rgcData?.country
            countryCode = bmkLocation.rgcData?.countryCode
            
            province = bmkLocation.rgcData?.province
            city = bmkLocation.rgcData?.city
            cityCode = bmkLocation.rgcData?.cityCode
            district = bmkLocation.rgcData?.district
            street = bmkLocation.rgcData?.street
            streetNumber = bmkLocation.rgcData?.streetNumber
            
            adCode = bmkLocation.rgcData?.adCode
        }
    }
    
}

