//
//  WDPhotoAlbumListTableViewCell.swift
//  WDPhotoSelector-Swift
//
//  Created by wudan on 2019/4/20.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit

// MARK: - 相册列表Cell
class WDPhotoAlbumListTableViewCell: UITableViewCell {

    /// 第一张现实的图片
    lazy var coverImage: UIImageView = {
        let i = UIImageView.init()
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    /// 标题 + 张数
    lazy var titleLabel: UILabel = {
        let b = UILabel.init()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.textColor = UIColor.black
        b.font = UIFont.systemFont(ofSize: 15)
        return b
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(coverImage)
        let con1 = NSLayoutConstraint.init(item: coverImage, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 15)
        let con2 = NSLayoutConstraint.init(item: coverImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 30)
        let con3 = NSLayoutConstraint.init(item: coverImage, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 10)
        let con4 = NSLayoutConstraint.init(item: coverImage, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: -10)
        self.contentView.addConstraints([con1, con2, con3, con4])
        
        contentView.addSubview(titleLabel)
        let con5 = NSLayoutConstraint.init(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -8)
        let con6 = NSLayoutConstraint.init(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: coverImage, attribute: .trailing, multiplier: 1, constant: 10)
        let con7 = NSLayoutConstraint.init(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0)
        self.contentView.addConstraints([con5, con6, con7])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
