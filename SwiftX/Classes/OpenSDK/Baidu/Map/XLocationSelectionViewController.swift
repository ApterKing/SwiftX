//
//  XLocationSelectionViewController.swift
//  SnapKit
//
//  Created by wangcong on 2019/3/7.
//

import UIKit
//import BaiduMapAPI_Map
//import BaiduMapAPI_Base
//import BaiduMapAPI_Search
//import BMKLocationKit

final public class XLocationSelectionViewController: XBaseViewController {
    
    public typealias LocationSelectedHandler = ((_ info: SelectedLocationInfo?) -> Void)
    
    private lazy var searchBar: XSearchBar = {
        let sb = XSearchBar(frame: CGRect(x: 10, y: 10, width: UIScreen.width - 20, height: 50))
        sb.backgroundImage = UIImage(color: UIColor.white)
        sb.barTintColor = UIColor.white
        sb.barStyle = .default
        sb.layer.cornerRadius = 5
        sb.delegate = self
        sb.placeholder = "小区/写字楼/学校"
        sb.showsCancelButton = false
        return sb
    }()
    
    private lazy var mapView: BMKMapView = {
        let mapView = BMKMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight))
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isOverlookEnabled = true
        mapView.mapType = BMKMapType.standard
        mapView.maxZoomLevel = 21
        mapView.minZoomLevel = 12
        mapView.zoomLevel = 16
        return mapView
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.frame = CGRect(x: searchBar.x, y: searchBar.y + searchBar.height + 10, width: UIScreen.width - 2 * searchBar.x, height: UIScreen.height - UIScreen.navigationBarHeight - (searchBar.y + searchBar.height + 10) - UIScreen.homeIndicatorMoreHeight - 30)
        tv.isHidden = true
        tv.register(LocationTableViewCell.self, forCellReuseIdentifier: "identifier")
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private lazy var pinImageView: UIImageView = {
        let imgv = UIImageView(frame: CGRect(x: (UIScreen.width - 18) / 2.0, y: mapView.height / 2.0 - 35, width: 18, height: 35))
        imgv.contentMode = .scaleAspectFill
        imgv.image = UIImage(named: "icon_map_pin_blue", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        imgv.isHidden = true
        return imgv
    }()
    
    private lazy var locationButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.width - 40 - 15, y: UIScreen.height - UIScreen.navigationBarHeight - UIScreen.homeIndicatorMoreHeight - 64, width: 44, height: 44))
        button.setImage(UIImage(named: "icon_map_location", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var geoSearch: BMKGeoCodeSearch = {
        let search = BMKGeoCodeSearch()
        search.delegate = self
        return search
    }()
    
    private lazy var poiSearch: BMKPoiSearch = {
        let search = BMKPoiSearch()
        return search
    }()
    private var selectedInfo: SelectedLocationInfo?
    
    private var poiInfos: [BMKPoiInfo] = []
    private var handler: LocationSelectedHandler?
    private var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 30.58, longitude: 103.92)

    override public func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardObserver()

        _initUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.delegate = self
        poiSearch.delegate = self
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.viewWillDisappear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.delegate = nil
        poiSearch.delegate = nil
        XLocationManager.default.stopUpdatingLocation()
    }
    
}

extension XLocationSelectionViewController {
    
    private func _initUI() {
        navigationItem.title = title ?? "选择地址"
        isNavigationBarHiddenIfNeeded = false
        
        let options: [UIControlStateOption] = [.title("确定", UIColor(hexColor: "#66B30C"), .normal),
                                               .title("确定", UIColor(hexColor: "#a0a0a5"), .disabled),
                                               .title("确定", UIColor(hexColor: "#66B30C").withAlphaComponent(0.7), .highlighted)
                                            ]
        navigationItem.rightBarButtonItem = customBarButtonItem(options: options, size: CGSize(width: 60, height: 44), isBackItem: false, left: false, handler: { [weak self] (_) in
            self?.searchBar.resignFirstResponder()
            self?.handler?(nil)
            currentNavigationController?.popViewController(animated: true)
        })
        
        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(pinImageView)
        view.addSubview(locationButton)
        view.addSubview(tableView)
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        XLocationManager.default.startUpdatingLocation { [weak self] (info, error) in
            if let location = info?.location {
                self?.currentLocation = location.coordinate
                self?._updateMapStatus(location.coordinate)
            }
        }
    }
    
    // 移动地图视图到中间
    private func _updateMapStatus(_ location: CLLocationCoordinate2D) {
        let mapStatus = BMKMapStatus()
        mapStatus.targetGeoPt = location
        mapStatus.targetScreenPt = CGPoint(x: mapView.width / 2.0, y: mapView.height / 2.0)
        mapView.setMapStatus(mapStatus, withAnimation: true, withAnimationTime: 350)
    }
    
}

extension XLocationSelectionViewController {
    
    static public func show(with handler: LocationSelectedHandler? = nil) {
        let vc = XLocationSelectionViewController()
        vc.handler = handler
        vc.hidesBottomBarWhenPushed = true
        currentNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension XLocationSelectionViewController: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let keyword = searchBar.text {
            let option = BMKPOINearbySearchOption()
            option.keywords = [keyword] //keyword.components(separatedBy: ",")
            option.location = currentLocation
//            option.scope = BMKPOISearchScopeType.BMK_POI_SCOPE_DETAIL_INFORMATION
            option.pageSize = 20
            poiSearch.delegate = self
            let success = poiSearch.poiSearchNear(by: option)
            print("OpenSDK   searchBarSearchButtonClicked   \(success)")
        }
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension XLocationSelectionViewController: BMKMapViewDelegate {
    
    public func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        XLocationManager.default.startUpdatingLocation { [weak self] (info, error) in
            self?.pinImageView.isHidden = false
            if let location = info?.location {
                self?.currentLocation = location.coordinate
                self?._updateMapStatus(location.coordinate)
            }
        }
    }
    
    public func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        let option = BMKReverseGeoCodeSearchOption()
        option.location = mapView.centerCoordinate
        geoSearch.reverseGeoCode(option)
    }
    
}

extension XLocationSelectionViewController: BMKGeoCodeSearchDelegate {
    
    public func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            selectedInfo = SelectedLocationInfo(result)
            searchBar.text = result.address
            print("OpenSDK    onGetReverseGeoCodeResult   \(searchBar.text)")
        }
        print("OpenSDK    onGetReverseGeoCodeResult   \(error == BMK_SEARCH_NO_ERROR)")
    }
    
}

extension XLocationSelectionViewController: BMKPoiSearchDelegate {
    
    public func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            if poiResult.totalPOINum != 0 {
                tableView.isHidden = false
                tableView.reloadData()
            }
        }
    }
    
}

extension XLocationSelectionViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiInfos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "identifier") as? LocationTableViewCell {
            let poiInfo = poiInfos[indexPath.row]
            cell.text0Label.text = poiInfo.address
            cell.text1Label.text = "\(poiInfo.city)\(poiInfo.area)"
            return cell
        }
        return UITableViewCell()
    }
    
}

extension XLocationSelectionViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        _updateMapStatus(poiInfos[indexPath.row].pt)
    }
    
}


extension XLocationSelectionViewController {
    
    /// 回调参数
    public class SelectedLocationInfo: NSObject {
        
        public var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        public var address: String = ""
        
        public var country: String?
        public var province: String?
        public var city: String?
        public var district: String?
        public var adCode: String?
        
        fileprivate convenience init(_ result: BMKReverseGeoCodeSearchResult) {
            self.init()
            location = result.location
            address = result.address

            country = result.addressDetail.country
            province = result.addressDetail.province
            city = result.addressDetail.city
            district = result.addressDetail.district
            adCode = result.addressDetail.adCode
        }
    }
    
}

extension XLocationSelectionViewController {
    
    fileprivate class LocationTableViewCell: UITableViewCell {
        
        static let height: CGFloat = 60
        
        lazy var text0Label: UILabel = {
            let label = UILabel(frame: CGRect(x: 15, y: 15, width: UIScreen.width - 30, height: 20))
            label.font = UIFont.systemFont(ofSize: 17)
            label.textColor = UIColor(hexColor: "#333333")
            return label
        }()
        
        lazy var text1Label: UILabel = {
            let label = UILabel(frame: CGRect(x: 15, y: LocationTableViewCell.height - 15 - 20, width: UIScreen.width - 30, height: 20))
            label.font = UIFont.systemFont(ofSize: 17)
            label.textColor = UIColor(hexColor: "#666666")
            return label
        }()
        
        lazy var separatorLine: UIView = {
            let view = UIView(frame: CGRect(x: 15, y: LocationTableViewCell.height - 0.5, width: UIScreen.width - 30, height: 0.5))
            view.backgroundColor = UIColor(hexColor: "#f7f7f7")
            return view
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = UIColor(hexColor: "#f7f7f7")
            self.selectedBackgroundView = selectedBackgroundView
            separatorInset = UIEdgeInsets(top: 0, left: UIScreen.width, bottom: 0, right: 0)
            
            addSubview(text0Label)
            addSubview(text1Label)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

