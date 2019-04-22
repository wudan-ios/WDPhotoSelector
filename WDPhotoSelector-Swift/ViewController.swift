//
//  ViewController.swift
//  WDPhotoSelector-Swift
//
//  Created by wudan on 2019/3/1.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "打开相册", style: .plain, target: self, action: #selector(listButtonTouched(sender:)))
    }
    
    @objc func listButtonTouched(sender: UIButton) {
        let vc = WDPhotoSeletorController()
        let options = WDAssetPickerOptions()
        options.maxAssetsCount = 3
        options.numOfAlbumListOneRow = 3
        options.videoPickable = false
        vc.setup(with: options)
        self.present(vc, animated: true, completion: nil)
    }
}

