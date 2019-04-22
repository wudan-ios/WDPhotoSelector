//
//  WDPhotoAlbumListView.swift
//  WDPhotoSelector-Swift
//
//  Created by wudan on 2019/4/20.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit

// MARK: - 相册列表View
class WDPhotoAlbumListView: UIButton {
    
    /// 选中相册回调
    var selectedAlbumBlock: ((AlbumModel) -> Void)?
    
    /// 是否让页面消失
    var selectedAlbumDimissBlock: (() -> Void)?
    
    /// TableView
    private lazy var tableView: UITableView = {
        let t = UITableView.init(frame: .zero, style: .plain)
        t.rowHeight = 65
        t.delegate = self
        t.dataSource = self
        t.tableFooterView = UIView.init()
        t.register(WDPhotoAlbumListTableViewCell.classForCoder(), forCellReuseIdentifier: "WDPhotoAlbumListTableViewCell")
        return t
    }()
    
    /// 相册model数组
    private var _albumArray:[AlbumModel] = Array()
    var albumArray:[AlbumModel] {
        get{
            return _albumArray
        } set {
            _albumArray = newValue
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        addSubview(tableView)
        addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 显示View
    func show() {
        tableView.frame = cALBUMLISTVIEW_TABLEVIEE_HIEDN_RECT
        backgroundColor = UIColor.init(white: 0, alpha: 0.0)
        frame = cALBUMLISTVIEW_RECT_SHOW_RECT
        UIView.animate(withDuration: 0.5) {
            if self.albumArray.count > 5 {
                self.tableView.frame = CGRect(x: 0, y: 0, width: cSCREEN_WIDTH, height: 65 * 5)
            } else {
                self.tableView.frame = CGRect(x: 0, y: 0, width: cSCREEN_WIDTH, height: CGFloat(self.albumArray.count) * 65.0)
            }
            self.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        }
    }
    
    // 隐藏View
    @objc func dismiss() {
        
        if selectedAlbumDimissBlock != nil {
            selectedAlbumDimissBlock!()
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.frame = cALBUMLISTVIEW_TABLEVIEE_HIEDN_RECT
            self.backgroundColor = UIColor.init(white: 0, alpha: 0.0)
        }) { (over) in
            self.frame = cALBUMLISTVIEW_RECT
        }
    }
}

extension WDPhotoAlbumListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:WDPhotoAlbumListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WDPhotoAlbumListTableViewCell") as! WDPhotoAlbumListTableViewCell
        let model:AlbumModel = albumArray[indexPath.row]
        WDPhotoSelectorManager.defaultManager.getPhoto(asset: (model.assetArray?.first?.asset)!, photoWidth: 100) { (image, info) -> (Void) in
            cell.coverImage.image = image
        }
        if let tempArray = model.assetArray {
            cell.titleLabel.text = model.albumName + "(\(String(describing: tempArray.count)))"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedAlbumBlock != nil {
            let model:AlbumModel = albumArray[indexPath.row]
            selectedAlbumBlock!(model)
        }
        dismiss()
    }
}
