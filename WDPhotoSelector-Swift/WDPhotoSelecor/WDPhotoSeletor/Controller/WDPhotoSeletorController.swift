//
//  WDPhotoSeletorController.swift
//  WDPhotoSelector-Swift
//
//  Created by wudan on 2019/4/20.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit

class WDAssetPickerOptions: NSObject {
    var maxAssetsCount: Int = 0
    var videoPickable: Bool = false
    var numOfAlbumListOneRow = 3
    var pickedAssetModels: [AssetModel] = Array()
}

// MARK: - 导航栏中间自定义按钮
class CenterDropView: UIControl {
    
    /// 标题
    var titleLabel: UILabel = {
        let t = UILabel.init()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    /// 图标
    var imageView: UIImageView = {
        let l = UIImageView.init()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    /// 重写isSeleted进行图标动画处理
    override var isSelected: Bool {
        didSet {
            if isSelected {
                UIView.animate(withDuration: 0.5) {
                    self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.imageView.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        let con0 = NSLayoutConstraint.init(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let con01 = NSLayoutConstraint.init(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let con1 = NSLayoutConstraint.init(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let con2 = NSLayoutConstraint.init(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        self.addConstraints([con0, con01, con1, con2])
        
        addSubview(imageView)
        let con3 = NSLayoutConstraint.init(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let con4 = NSLayoutConstraint.init(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let con5 = NSLayoutConstraint.init(item: imageView, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1, constant: 10)
        self.addConstraints([con3, con4, con5])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 自定义导航栏
class WDNavigationBarView: UIView {
    
    /// 取消按钮
    lazy var cancelButton: UIButton = {
        let b = UIButton.init()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage.init(named: "picker_cancel"), for: .normal)
        return b
    }()
    
    /// 底部线条
    lazy var bottomLine: UIView = {
        let v = UIView.init()
        v.backgroundColor = UIColor.lightGray
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    /// 中间下拉按钮
    lazy var centerButton: CenterDropView = {
        let b = CenterDropView.init(frame: CGRect.zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(cancelButton)
        let constraints1 = NSLayoutConstraint.init(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -22)
        let constraints2 = NSLayoutConstraint.init(item: cancelButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 15)
        self.addConstraints([constraints1, constraints2])
        
        addSubview(centerButton)
        let constraints3 = NSLayoutConstraint.init(item: centerButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -22)
        let constraints4 = NSLayoutConstraint.init(item: centerButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraints([constraints3, constraints4])
        
        addSubview(bottomLine)
        let constraints5 = NSLayoutConstraint.init(item: bottomLine, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let constraints6 = NSLayoutConstraint.init(item: bottomLine, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let constraints7 = NSLayoutConstraint.init(item: bottomLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let constraints8 = NSLayoutConstraint.init(item: bottomLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0.5)
        self.addConstraints([constraints5, constraints6, constraints7, constraints8])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - 主控制器
class WDPhotoSeletorController: UIViewController {
    // MARK: - UI
    /// 自定义导航栏
    private lazy var navatioanBarView: WDNavigationBarView = {
        let v = WDNavigationBarView.init(frame: cNAVIGATIONBARVIEW_RECT)
        v.backgroundColor = .white
        v.centerButton.imageView.image = UIImage.init(named: "arrow_down_icon")
        v.centerButton.addTarget(self, action: #selector(centerButtonTouched(sender:)), for: .touchUpInside)
        v.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return v
    }()
    
    /// CollectionView视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = cROW_SECTION_INSTER
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: heightOfAlbumListOneRow, height: heightOfAlbumListOneRow)
        let c = UICollectionView.init(frame: cCOLLECTIONVIEW_RECT, collectionViewLayout: layout)
        c.backgroundColor = .white
        c.register(WDPhotoSeletorCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "WDPhotoSeletorCollectionViewCell")
        c.delegate = self
        c.dataSource = self
        return c
    }()
    
    /// 相册列表
    private lazy var albumListView: WDPhotoAlbumListView = {
        let v = WDPhotoAlbumListView.init(frame: cALBUMLISTVIEW_RECT)
        v.selectedAlbumDimissBlock = {
            self.navatioanBarView.centerButton.isSelected = false
        }
        v.selectedAlbumBlock = { model in
            self.model = model
            if let tempModel = self.model {
                self.navatioanBarView.centerButton.titleLabel.text = tempModel.albumName
            }
            self.collectionView.reloadData()
            self.refreshAlbumAssetsStatus()
        }
        return v
    }()
    
    // MARK: - Data
    private var heightOfAlbumListOneRow: CGFloat = 0.0
    
    // 配置选项
    private var options: WDAssetPickerOptions?
    func setup(with theOptions: WDAssetPickerOptions) {
        options = theOptions
        let barSpace: CGFloat = 10.0 * 2
        let width = cSCREEN_WIDTH - barSpace - 10.0 * CGFloat((theOptions.numOfAlbumListOneRow - 0))
        heightOfAlbumListOneRow = width / CGFloat(theOptions.numOfAlbumListOneRow)
    }
    
    /// 选中cell的index
    private var albumSelectedIndexpaths: [IndexPath] = Array()
    
    /// 获取当前视图的相册模型
    private var model:AlbumModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(navatioanBarView)
        view.addSubview(collectionView)
        view.addSubview(albumListView)
        getAlbumList()
    }
    
    deinit {
        print("=====【\(self.classForCoder)】===== Deinit")
    }
}

@objc private extension WDPhotoSeletorController {
    // 导航栏TitleView 点击按钮
    func centerButtonTouched(sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            albumListView.show()
        } else {
            albumListView.dismiss()
        }
    }
    
    // Controller Dismiss
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    // 获取相册
    func getAlbumList() {
        WDPhotoSelectorManager.defaultManager.handleAuthorization { (status) -> (Void) in
            switch status {
            case .Authorized:
                WDPhotoSelectorManager.defaultManager.getAllAlbums(allowPickingVideo: false, completion: { (modelArray) -> (Void) in
                    self.albumListView.albumArray = modelArray
                    self.model = modelArray.first
                    if let tempModel = self.model {
                        self.navatioanBarView.centerButton.titleLabel.text = tempModel.albumName
                    }
                    self.collectionView.reloadData()
                })
                
                WDPhotoSelectorManager.defaultManager.photoLibraryChanged(block: {
                    WDPhotoSelectorManager.defaultManager.getAllAlbums(allowPickingVideo: false, completion: { (modelArray) -> (Void) in
                        self.albumListView.albumArray = modelArray
                        self.model = modelArray.first
                        DispatchQueue.main.async {
                            if let tempModel = self.model {
                                self.navatioanBarView.centerButton.titleLabel.text = tempModel.albumName
                            }
                            self.collectionView.reloadData()
                        }
                    })
                })
                
            case .Denied: break
            case .NotDetermined: break
            case .Restricted: break
            }
        }
    }
    
    // 刷新视图
    func refreshAlbumAssetsStatus() {
        albumSelectedIndexpaths = Array()
        for (index, model) in (model?.assetArray?.enumerated())! {
            model.picked = false
            model.number = 0
            for m in options!.pickedAssetModels.enumerated() {
                if m.element.asset?.localIdentifier == model.asset?.localIdentifier {
                    model.picked = true
                    model.number = m.offset + 1
                    albumSelectedIndexpaths.append(IndexPath.init(item: index, section: 0))
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension WDPhotoSeletorController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let tempModel = model {
            return (tempModel.assetArray?.count)!
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WDPhotoSeletorCollectionViewCell", for: indexPath) as? WDPhotoSeletorCollectionViewCell
        
        if let cell = cell {
            if let array = model?.assetArray {
                cell.setupView(with: array[indexPath.item])
                cell.selectActionBlock = { [weak cell] (_model, isSelected) in
                    guard let strongCell = cell else { return }
                    self.opeartion(of: strongCell, model: _model, isSelected: isSelected)
                }
            }
        }
        return cell!
    }
    
    /// 按钮点击操作
    private func opeartion(of cell: WDPhotoSeletorCollectionViewCell, model: AssetModel, isSelected: Bool) {
        if isSelected {
            cell.selectButton.isSelected = false
            model.picked = false
            model.number = 0
            for (index, assetModel) in self.options!.pickedAssetModels.enumerated() {
                if assetModel.asset?.localIdentifier == model.asset?.localIdentifier {
                    assetModel.number = 0
                    assetModel.picked = false
                    self.options?.pickedAssetModels.remove(at: index)
                }
            }
            cell.selectButton.setTitle("", for: .normal)
        } else {
            let currentCount: Int = (self.options?.pickedAssetModels.count)!
            let maxCount: Int = self.options!.maxAssetsCount
            if currentCount < maxCount {
                model.picked = true
                cell.selectButton.isSelected = true
                self.options?.pickedAssetModels.append(model)
                if let count = self.options?.pickedAssetModels.count {
                    let titleString: String = "\(count)"
                    cell.selectButton.setTitle(titleString, for: .normal)
                }
            }
        }
        self.refreshAlbumAssetsStatus()
        if (self.albumSelectedIndexpaths.count > 0 && isSelected) {
            collectionView.reloadItems(at: self.albumSelectedIndexpaths)
        }
    }
}


// MARK: - UICollectionViewDelegate
extension WDPhotoSeletorController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let tempModel = model {
            let browser = WDPhotoBrowser(assetModelArray: tempModel.assetArray!, originView: collectionView.cellForItem(at: indexPath)! as! WDPhotoSeletorCollectionViewCell, currentIndex: indexPath.item) { (index) -> (WDPhotoSeletorCollectionViewCell) in
                collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: .bottom, animated: false)
                collectionView.layoutIfNeeded()
                return collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as! (WDPhotoSeletorCollectionViewCell)
            }
            browser.showView()
        }
    }
}

