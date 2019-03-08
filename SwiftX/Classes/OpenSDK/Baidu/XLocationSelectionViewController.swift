//
//  XLocationSelectionViewController.swift
//  SnapKit
//
//  Created by wangcong on 2019/3/7.
//

import UIKit
import BaiduMapAPI_Map
import BaiduMapAPI_Base
import BaiduMapAPI_Search
import BMKLocationKit

final public class XLocationSelectionViewController: XBaseViewController {
    
    public typealias LocationSelectedHandler = ()
    
    private lazy var searchBar: XSearchBar = {
        let sb = XSearchBar(frame: CGRect.zero)
        sb.becomeFirstResponder()
        sb.delegate = self
        sb.placeholder = "请输入地址关键字"
        sb.showsCancelButton = true
        return sb
    }()
    
    private lazy var mapView: BMKMapView = {
        let mapView = BMKMapView(frame: CGRect.zero)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isOverlookEnabled = true
        mapView.mapType = BMKMapType.standard
        mapView.showMapScaleBar = false
        mapView.maxZoomLevel = 21
        mapView.minZoomLevel = 12
        mapView.zoomLevel = 16
        mapView.isBuildingsEnabled = true
        return mapView
    }()
    
    private lazy var locationManager: BMKLocationManager {
        let manager = BMKLocationManager()
        manager.delegate = self
        return manager
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView.default
        tv.register(LocationTableViewCell.self, forCellReuseIdentifier: "identifier")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.delegate = self
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.viewWillDisappear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.delegate = nil
    }
    
}

extension XLocationSelectionViewController {
    
    private func _initUI() {
        navigationItem.title = title ?? "选择地址"
    
    
    }
    
}

extension XLocationSelectionViewController: UISearchBarDelegate {
    
}

extension XLocationSelectionViewController: BMKMapViewDelegate {
    
    public func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        
    }
    
    public func mapView(_ mapView: BMKMapView!, regionWillChangeAnimated animated: Bool) {
        
    }
    
    public func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        
    }
    
}

extension XLocationSelectionViewController: BMKLocationManagerDelegate {
    

}

extension XLocationSelectionViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "identifier") as? LocationTableViewCell {
            return cell
        }
        return UITableViewCell()
    }
    
}

extension XLocationSelectionViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension XLocationSelectionViewController {
    
    /// 回调参数
    public class LocationInfo: Codable {
        
    }
    
}

extension XLocationSelectionViewController {
    
    fileprivate class LocationTableViewCell: UITableViewCell {
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

