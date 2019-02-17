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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.width, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        return tableView
    }
    
}
