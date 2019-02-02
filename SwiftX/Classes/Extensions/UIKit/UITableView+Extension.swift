//
//  UITableView+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/29.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

public extension UITableView {
    
    class var `default`: UITableView {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        return tableView
    }
    
}
