//
//  UICollectionView+Extension.swift
//  SwiftX
//
//  Created by wangcong on 2018/11/27.
//  Copyright © 2018 wangcong. All rights reserved.
//

import UIKit

public extension UICollectionView {
    
    class var `default`: UICollectionView {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowlayout)
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }
    
}
