//
//  XActionSheet.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/27.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

@objc protocol XActionSheetDelegate {
    @objc optional func actionSheet(actionSheet: XActionSheet, didClickedAt index: Int)
}

public class XActionSheet: UIViewController {
    private static let kActionSheedItemHeight: CGFloat = 50
    
    private static let window: UIWindow = {
        let window = UIWindow()
        window.isHidden = true
        window.windowLevel = UIWindow.Level.statusBar + 0.01
        window.backgroundColor = UIColor.clear
        window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        return window
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "identifier")
        return tableView
    }()
    
    private var buttonTitles = [String]()
    private var destructButtonIndex:Int = -1
    private weak var delegate:XActionSheetDelegate?
    private var clickBlock: ((_ index: Int) -> Void)?
    private var isStatusBarColorBlack = true
    private var disableIndexArr = [Int]()

    init(delegate: XActionSheetDelegate, buttonTitles: String...) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = delegate
        self.buttonTitles = buttonTitles
    }
    
    init(clickBlock: @escaping (_ index: Int) -> Void, buttonTitles: String...) {
        super.init(nibName: nil, bundle: nil)
        self.clickBlock = clickBlock
        self.buttonTitles = buttonTitles
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        _initUI();
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return isStatusBarColorBlack ? UIStatusBarStyle.default : UIStatusBarStyle.lightContent
    }
    
}

/// MARK: private
extension XActionSheet {
    private func _initUI () {
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        let screenWidht = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        let tapBtn = UIButton()
        tapBtn.frame = CGRect(x: 0, y: 0, width: screenWidht, height: screenHeight)
        tapBtn.addTarget(self, action: #selector(XActionSheet._dismiss), for: UIControl.Event.touchUpInside)
        view.addSubview(tapBtn)
        
        let tableViewHeight = XActionSheet.kActionSheedItemHeight * CGFloat(buttonTitles.count)
        tableView.frame = CGRect(x: 0, y: screenHeight, width: screenWidht, height: tableViewHeight)
        view.addSubview(tableView)
        tableView.reloadData()
    }
    
    private func _checkCellSeperator(cell: UITableViewCell, indexPath: IndexPath) {
        var splitLine = cell.viewWithTag(10001)
        if splitLine == nil {
            splitLine = UIView()
            splitLine?.backgroundColor = UIColor(hexColor: "0xeeeeee")
            splitLine?.tag = 10001
            splitLine?.frame = CGRect(x: 20, y: XActionSheet.kActionSheedItemHeight - 1, width: cell.bounds.size.width - 40, height: 1)
            cell.addSubview(splitLine!)
        }
        
        splitLine?.isHidden = (indexPath.row == buttonTitles.count - 1)
    }
    
    
    @objc func _dismiss() {
        if self === XActionSheet.window.rootViewController {
            var frame = tableView.frame
            frame.origin.y = UIScreen.main.bounds.size.height
            UIView.animate(withDuration: 0.3, animations: {
                XActionSheet.window.alpha = 0
                self.tableView.frame = frame ?? CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: 0, height: 0)
            }) { (success) in
                XActionSheet.window.removeFromSuperview()
                XActionSheet.window.isHidden = true
                XActionSheet.window.rootViewController = nil
            }
        }
    }
    
    private func checkIsInIndexArr(index: Int) -> Bool {
        return self.disableIndexArr.contains(index)
    }
}

/// MARK: public
public extension XActionSheet {
    public func show () {
        let window = XActionSheet.window
        window.rootViewController = self
        window.alpha = 0
        window.isHidden = false
        UIResponder.currentFirstResponder()?.resignFirstResponder()
        
        var frame = tableView.frame
        frame.origin.y = UIScreen.main.bounds.size.height - frame.size.height
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            window.alpha = 1
            self.tableView.frame = frame
        })
    }
}

/// MAKR: UITableViewDataSource
extension XActionSheet: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonTitles.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
        
        cell.textLabel?.text = buttonTitles[indexPath.row]
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.selectionStyle = self.checkIsInIndexArr(index: indexPath.row) ? UITableViewCell.SelectionStyle.none : UITableViewCell.SelectionStyle.default
        _checkCellSeperator(cell: cell, indexPath: indexPath)
        
        if indexPath.row == destructButtonIndex {
            cell.textLabel?.textColor = UIColor(hexColor: "0xd43003")
        } else {
            cell.textLabel?.textColor = UIColor(hexColor: "0x777777")
        }
        
        return cell
    }
}

/// MAKR: UITableViewDelegate
extension XActionSheet: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return XActionSheet.kActionSheedItemHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.checkIsInIndexArr(index: indexPath.row) {
            delegate?.actionSheet?(actionSheet: self, didClickedAt: indexPath.row)
            clickBlock?(indexPath.row)
            self._dismiss()
        }
    }
}
