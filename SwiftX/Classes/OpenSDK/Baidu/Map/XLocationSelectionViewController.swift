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
        let mapView = BMKMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - UIScreen.navigationBarHeight - UIScreen.homeIndicatorMoreHeight))
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
        tv.backgroundColor = UIColor.white
        tv.isHidden = true
        tv.register(LocationTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(LocationTableViewCell.self))
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
        let button = UIButton(frame: CGRect(x: UIScreen.width - 40 - 15, y: UIScreen.height - UIScreen.navigationBarHeight - UIScreen.homeIndicatorMoreHeight - 54, width: 54, height: 54))
        button.setImage(UIImage(named: "icon_map_location", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var geoSearch: BMKGeoCodeSearch = {
        let search = BMKGeoCodeSearch()
        search.delegate = self
        return search
    }()
    
    private var poiSearchCity: String?
    private lazy var poiSearch: BMKPoiSearch = {
        let search = BMKPoiSearch()
        return search
    }()
    
    // 点击确定后回调的数据
    private var selectedInfo: SelectedLocationInfo?
    
    private var poiInfos: [BMKPoiInfo] = []
    private var handler: LocationSelectedHandler?
    private var currentLocation: CLLocationCoordinate2D?

    override public func viewDidLoad() {
        super.viewDidLoad()
        _initUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
        mapView.delegate = self
        poiSearch.delegate = self
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            guard let weakSelf = self else { return }
            weakSelf.searchBar.resignFirstResponder()
            weakSelf.handler?(weakSelf.selectedInfo)
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
    private func _updateMapStatus(_ location: CLLocationCoordinate2D, _ shouldGeoSearch: Bool = false) {
        let mapStatus = BMKMapStatus()
        mapStatus.targetGeoPt = location
        mapStatus.targetScreenPt = CGPoint(x: mapView.width / 2.0, y: mapView.height / 2.0)
        mapView.setMapStatus(mapStatus, withAnimation: true, withAnimationTime: 350)
        
        if shouldGeoSearch {
            let option = BMKReverseGeoCodeSearchOption()
            option.location = mapView.centerCoordinate
            geoSearch.reverseGeoCode(option)
        }
    }
    
    private func _poiSearch(keywords: [String], location: CLLocationCoordinate2D) {
//        let option = BMKPOINearbySearchOption()
//        option.keywords = keywords
//        option.location = location
//        option.radius = 1000000000
        let option = BMKPOICitySearchOption()
        option.keyword = keywords[0]
        option.city = poiSearchCity ?? (XLocationManager.default.locationInfo?.city ?? "成都市")
        option.pageSize = 20
        poiSearch.delegate = self
//        poiSearch.poiSearchNear(by: option)
        poiSearch.poiSearch(inCity: option)
    }
    
}

extension XLocationSelectionViewController {
    
    static public func show(coordinate: CLLocationCoordinate2D? = nil, poiSearchCity: String? = nil, with handler: LocationSelectedHandler? = nil) {
        let vc = XLocationSelectionViewController()
        if coordinate != nil {
            vc.currentLocation = coordinate!
        }
        if poiSearchCity != nil {
            vc.poiSearchCity = poiSearchCity
        }
        vc.handler = handler
        vc.hidesBottomBarWhenPushed = true
        currentNavigationController?.pushViewController(vc, animated: true)
    }
    
}

extension XLocationSelectionViewController: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let keyword = searchBar.text, let location = currentLocation {
            _poiSearch(keywords: [keyword], location: location)
        }
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension XLocationSelectionViewController: BMKMapViewDelegate {
    
    public func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        selectedInfo = SelectedLocationInfo()
        if let location = self.currentLocation {
            pinImageView.isHidden = false
            _updateMapStatus(location, true)
        } else {
            XLocationManager.default.startUpdatingLocation { [weak self] (info, error) in
                self?.pinImageView.isHidden = false
                if let location = info?.location {
                    self?.currentLocation = location.coordinate
                    self?._updateMapStatus(location.coordinate, true)
                }
            }
        }
    }
    
    public func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool, reason: BMKRegionChangeReason) {
        selectedInfo?.location = mapView.centerCoordinate
    }
    
}

extension XLocationSelectionViewController: BMKGeoCodeSearchDelegate {
    
    public func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            selectedInfo = SelectedLocationInfo()
            selectedInfo?.address = result.address
            selectedInfo?.location = result.location
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
                poiInfos = poiResult.poiInfoList.filter({ (info) -> Bool in
                    return info.address != ""
                })
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LocationTableViewCell.self)) as? LocationTableViewCell {
            let poiInfo = poiInfos[indexPath.row]
            cell.separatorLine.isHidden = indexPath.row == poiInfos.count - 1
            cell.text0Label.text = poiInfo.address
            cell.text1Label.text = "\(poiInfo.city ?? "")\(poiInfo.area ?? "")"
            return cell
        }
        return UITableViewCell()
    }
    
}

extension XLocationSelectionViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LocationTableViewCell.height
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        let poiInfo = poiInfos[indexPath.row]
        selectedInfo?.address = poiInfo.address
        selectedInfo?.location = poiInfo.pt
        
        searchBar.text = poiInfo.address
        _updateMapStatus(poiInfo.pt)
    }
    
}


extension XLocationSelectionViewController {
    
    /// 回调参数
    public class SelectedLocationInfo: NSObject {
        public var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        public var address: String = ""
    }
    
}

extension XLocationSelectionViewController {
    
    fileprivate class LocationTableViewCell: UITableViewCell {
        
        static let height: CGFloat = 60
        
        lazy var text0Label: UILabel = {
            let label = UILabel(frame: CGRect(x: 15, y: 10, width: UIScreen.width - 50, height: 20))
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = UIColor(hexColor: "#333333")
            return label
        }()
        
        lazy var text1Label: UILabel = {
            let label = UILabel(frame: CGRect(x: 15, y: LocationTableViewCell.height - 10 - 20, width: UIScreen.width - 50, height: 20))
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(hexColor: "#666666")
            return label
        }()
        
        lazy var separatorLine: UIView = {
            let view = UIView(frame: CGRect(x: 15, y: LocationTableViewCell.height - 1, width: UIScreen.width - 30, height: 1))
            view.backgroundColor = UIColor(hexColor: "#f7f7f7")
            return view
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = UIColor(hexColor: "#f7f7f7")
            self.selectedBackgroundView = selectedBackgroundView
            separatorInset = UIEdgeInsets(top: 0, left: UIScreen.width, bottom: 0, right: 0)
            
            contentView.addSubview(text0Label)
            contentView.addSubview(text1Label)
            contentView.addSubview(separatorLine)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

