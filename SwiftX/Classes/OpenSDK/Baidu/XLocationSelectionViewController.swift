//
//  XLocationSelectionViewController.swift
//  SnapKit
//
//  Created by wangcong on 2019/3/7.
//

import UIKit

final public class XLocationSelectionViewController: XBaseViewController {
    
    public typealias LocationSelectedHandler = ()
    
    private lazy var searchBar: XSearchBar = {
        let sb = XSearchBar(frame: CGRect.zero)
        sb.becomeFirstResponder()
        sb.delegate = self
        sb.placeholder = "请输入关键字搜索"
        sb.showsCancelButton = true
        return sb
    }()
    
    private lazy var mapView: BMKMapView = {
        let map = BMKMapView(frame: CGRect.zero)
        map.delegate = self
        return map
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

