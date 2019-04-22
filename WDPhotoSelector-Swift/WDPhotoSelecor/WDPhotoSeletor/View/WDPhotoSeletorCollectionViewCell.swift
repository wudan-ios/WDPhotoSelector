//
//  WDPhotoSeletorCollectionViewCell.swift
//  WDPhotoSelector-Swift
//
//  Created by wudan on 2019/4/20.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit
import FLAnimatedImage

// MARK: - 相册Cell
class WDPhotoSeletorCollectionViewCell: UICollectionViewCell {
    /// 主体图片
    lazy var imageView: UIImageView = {
        let i = UIImageView.init()
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    var selectActionBlock:((_ model: AssetModel, _ buttonIsSelected: Bool) -> Void)?
    
    /// 选择按钮
    lazy var selectButton: UIButton = {
        let b = UIButton.init(type: .custom)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(nil, for: .selected)
        b.layer.cornerRadius = 12.5 * cSCREEN_RETIO
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(selectButtonTouched(sender:)), for: .touchUpInside)
        b.setBackgroundImage(UIImage(named: "picker_unselected"), for: .normal)
        b.setBackgroundImage(UIImage(named: "picker_selected"), for: .selected)
        return b
    }()
    
    private var _model:AssetModel!

    func setupView(with model: AssetModel) {
        _model = model
        selectButton.isSelected = model.picked
        if !model.picked {
            selectButton.setTitle("", for: .normal)
        } else {
            selectButton.setTitle("\(model.number)", for: .normal)
        }
        WDPhotoSelectorManager.defaultManager.getPhoto(asset: model.asset!, photoWidth: cSCREEN_WIDTH) { (image, info) -> (Void) in
            self.imageView.image = image
        }
    }

    
    @objc func selectButtonTouched(sender: UIButton) {
        sender.shakeAniamtion()
        if selectActionBlock != nil {
            selectActionBlock!(_model!, sender.isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        let con1 = NSLayoutConstraint.init(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
        let con2 = NSLayoutConstraint.init(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
        let con3 = NSLayoutConstraint.init(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        let con4 = NSLayoutConstraint.init(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        self.contentView.addConstraints([con1, con2, con3, con4])
        
        contentView.addSubview(selectButton)
        let con5 = NSLayoutConstraint.init(item: selectButton, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -8 * cSCREEN_RETIO)
        let con6 = NSLayoutConstraint.init(item: selectButton, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 8 * cSCREEN_RETIO)
        let con7 = NSLayoutConstraint.init(item: selectButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25 * cSCREEN_RETIO)
        let con8 = NSLayoutConstraint.init(item: selectButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 25 * cSCREEN_RETIO)
        contentView.addConstraints([con5, con6, con7, con8])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
