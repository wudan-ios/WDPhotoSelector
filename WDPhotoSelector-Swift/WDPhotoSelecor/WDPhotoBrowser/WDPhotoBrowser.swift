//
//  WDPhotoBrowser.swift
//  WDPhotoSelector-Swift
//
//  Created by wudan on 2019/4/10.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit

class WDPhotoBrowser: UIView {
    
    // MARK: - private
    private var _scrollViewIndexBlock: ((_ scrollViewIndex: Int) -> (WDPhotoSeletorCollectionViewCell))!
    private var _assetModelArray: [AssetModel] = Array()
    private var _originView: WDPhotoSeletorCollectionViewCell!
    private var _currentIndex: Int = 0
    private lazy var _collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.itemSize = cSCREEN_SIZE
        layout.scrollDirection = .horizontal
        let c = UICollectionView.init(frame: cSCREEN_BOUNDS, collectionViewLayout: layout)
        c.backgroundColor = .clear
        c.isPagingEnabled = true
        c.dataSource = self
        c.delegate = self
        c.bounces = false
        c.showsHorizontalScrollIndicator = false
        c.register(WDPhotoBrowserImageCell.classForCoder(), forCellWithReuseIdentifier: "WDPhotoBrowserImageCell")
        return c
    }()
    
    /// 初始化
    ///
    /// - Parameters:
    ///   - assetModelArray: 图片模型数组
    ///   - originView: 起始实图
    ///   - currentIndex: 当前滚动到的下标
    ///   - scrollChangeViewBlock: 滚动视图回掉
    convenience init(assetModelArray: [AssetModel], originView: WDPhotoSeletorCollectionViewCell, currentIndex: Int, scrollChangeViewBlock: @escaping ((_ scrollViewIndex: Int) -> (WDPhotoSeletorCollectionViewCell))) {
        self.init()
        addSubview(_collectionView)
        _scrollViewIndexBlock = scrollChangeViewBlock
        _assetModelArray = assetModelArray
        _originView = originView
        _currentIndex = currentIndex
        _collectionView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func showViewAnimation() {
        _collectionView.scrollToItem(at: IndexPath.init(item: _currentIndex, section: 0), at: .right, animated: false)
        _collectionView.layoutIfNeeded()
        
        let cell = getPhotoBrowserImageCell(by: _currentIndex)
        let fromRect = _originView.convert(_originView.bounds, to: cell.contentView)
        cell.imageView.frame = fromRect
        
        UIView.animate(withDuration: 0.5) {
            cell.imageView.frame = self.getToRect(by: self._originView)
            self.backgroundColor = UIColor.init(white: 0, alpha: 1)
        }
    }
    
    private func getPhotoBrowserImageCell(by indexPathOfItem: Int) -> WDPhotoBrowserImageCell {
        let cell = _collectionView.cellForItem(at: IndexPath.init(item: indexPathOfItem, section: 0)) as? WDPhotoBrowserImageCell
        guard let cellT = cell else { return WDPhotoBrowserImageCell.init() }
        return cellT
    }
    
    /// 通过originCell获取动画执行的frame
    ///
    /// - Parameter originCell: 从首页中获取的Cell
    /// - Returns: 动画执行目标frame
    private func getToRect(by originCell: WDPhotoSeletorCollectionViewCell) -> CGRect {
        let width = originCell.imageView.image?.size.width
        let height = originCell.imageView.image?.size.height
        let imageRatio: CGFloat = width! / height!
        let screenRatio = cSCREEN_WIDTH / cSCREEN_HEIGHT
        var toRect: CGRect = .zero
        if imageRatio < screenRatio {
            let h = cSCREEN_HEIGHT
            let w = h * imageRatio
            toRect = CGRect(x: (cSCREEN_WIDTH - w) / 2, y: 0, width: w, height: h)
        } else {
            let w = cSCREEN_WIDTH
            let h = w / imageRatio
            toRect = CGRect(x: 0, y: (cSCREEN_HEIGHT - h) / 2, width: w, height: h)
        }
        return toRect
    }
    
    // 显示页面
    public func showView() {
        UIApplication.shared.keyWindow?.addSubview(self)
        frame = cSCREEN_BOUNDS
        backgroundColor = UIColor.init(white: 0, alpha: 0)
        showViewAnimation()
    }
    
    // 让页面消失
    @objc private func hidenView(cell: WDPhotoBrowserImageCell) {
       let toRect = _originView.convert(_originView.bounds, to: window)
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = UIColor.init(white: 0, alpha: 0)
            cell.imageView.frame = toRect
            cell.imageView.clipsToBounds = true
        }) { (complete) in
            self.removeFromSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension WDPhotoBrowser: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _assetModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WDPhotoBrowserImageCell", for: indexPath) as? WDPhotoBrowserImageCell
        if let cellT = cell {
            cellT.setup(with: _assetModelArray[indexPath.item])
            cellT.delegate = self
        }
        return cell!
    }
}

// MARK: - UICollectionViewDelegate
extension WDPhotoBrowser: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop {
            getIndex(by: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop {
            getIndex(by: scrollView)
        }
    }
    
    private func getIndex(by scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / cSCREEN_WIDTH)
        _originView = _scrollViewIndexBlock!(index)
    }
}

// MARK: - WDPhotoBrowserImageCellDelegate
extension WDPhotoBrowser: WDPhotoBrowserImageCellDelegate {
    func browserImageCellDidRecognizedSingleGuesture(cell: WDPhotoBrowserImageCell) {
        hidenView(cell: cell)
    }
    
    func browserImageCellDidRecognizedPanGuestureChange(cell: WDPhotoBrowserImageCell, percentScale: CGFloat) {
        backgroundColor = UIColor.init(white: 0, alpha: percentScale)
    }
    
    func browserImageCellDidRecognizedPanGuestureFinished(cell: WDPhotoBrowserImageCell) {
        hidenView(cell: cell)
    }
}
