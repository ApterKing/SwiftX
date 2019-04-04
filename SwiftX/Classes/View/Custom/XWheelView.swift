//
//  XWheelView.swift
//  FBusiness
//
//  Created by wangcong on 2019/4/2.
//

import UIKit

@objc public protocol XWheelViewDataSource: NSObjectProtocol {
    func numberOfItems(in wheelView: XWheelView) -> Int
    func wheelView(_ wheelView: XWheelView, cellForItemAt index: Int) -> UICollectionViewCell
}

@objc public protocol XWheelViewDelegate: NSObjectProtocol {
    @objc optional func wheelView(_ wheelView: XWheelView, didSelectItemAt index: Int)
    @objc optional func wheelView(_ wheelView: XWheelView, didScrollTo index: Int)
}

/// MARK: 通过UICollectionView实现的轮播控件
open class XWheelView: UIView {
    
    private let numberOfSections: Int = 100000
    
    private lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowlayout)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = UIColor.clear
        cv.isPagingEnabled = true
        cv.bounces = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl(frame: CGRect.zero)
        pc.currentPageIndicatorTintColor = UIColor(hexColor: "#66B30C")
        pc.pageIndicatorTintColor = UIColor.lightGray
        return pc
    }()
    private var currentIndexPath: IndexPath = IndexPath(row: 0, section: 0) {
        didSet {
            pageControl.currentPage = currentIndexPath.row
            delegate?.wheelView?(self, didScrollTo: pageControl.currentPage)
        }
    }
    private var timer: Timer?
    
    @IBInspectable
    open var dataSource: XWheelViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    @IBInspectable
    open var delegate: XWheelViewDelegate?
    
    @IBInspectable
    open var autoWheel: Bool = true {
        didSet {
            if autoWheel {
                _startTimer()
            } else {
                _stopTimer()
            }
        }
    }
    
    @IBInspectable
    open var wheelInterval: TimeInterval = 5
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        _initUI()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _initUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        _initUI()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        pageControl.frame = CGRect(x: 0, y: height - 30, width: width, height: 20)
        
        reloadData()
    }

}

/// MARK: private
extension XWheelView {
    
    private func _initUI() {
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    private func _startTimer() {
        guard autoWheel else { return }
        if timer?.isValid ?? false {
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: wheelInterval, repeats: true, block: { [weak self] (_) in
            self?._nextPage()
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func _stopTimer() {
        if timer?.isValid ?? false {
            timer?.invalidate()
        }
    }
    
    private func _nextPage() {
        let pages = dataSource?.numberOfItems(in: self) ?? 0
        guard pages > 0 else { return }
        
        if currentIndexPath.row == pages - 1 {
            currentIndexPath = IndexPath(row: 0, section: currentIndexPath.section + 1 >= numberOfSections ? numberOfSections / 2 : currentIndexPath.section + 1)
        } else {
            currentIndexPath = IndexPath(row: currentIndexPath.row + 1, section: currentIndexPath.section)
        }
        collectionView.scrollToItem(at: currentIndexPath, at: .left, animated: true)
    }
    
}

/// MARK: public
extension XWheelView {
    
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: currentIndexPath.section))
    }
    
    public func reloadData() {
        collectionView.reloadData()
        let pages = dataSource?.numberOfItems(in: self) ?? 0
        if pages > 0 {
            currentIndexPath = IndexPath(row: currentIndexPath.row, section: numberOfSections / 2)
            collectionView.scrollToItem(at: currentIndexPath, at: .left, animated: false)
        }
        pageControl.numberOfPages = pages
        pageControl.currentPage = currentIndexPath.row
        
        _startTimer()
    }

}

extension XWheelView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource?.wheelView(self, cellForItemAt: indexPath.row) ?? UICollectionViewCell()
    }
}

extension XWheelView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.wheelView?(self, didSelectItemAt: indexPath.row)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _stopTimer()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _startTimer()
        
        if let indexPath = collectionView.indexPathsForVisibleItems.last {
            currentIndexPath = indexPath
        }
    }
    
}
