//
//  WDPhotoSelectorManager.swift
//  WDPhotoSelector-Swift
//
//  Created by wudan on 2019/3/1.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit
import Photos
import JXPhotoBrowser
import FLAnimatedImage

// MARK: - 图片Model
class AssetModel: NSObject {
    
    /// PHAsset
    var asset: PHAsset?
    /// 选中状态 默认NO
    var picked: Bool = false
    /// 数字
    var number: Int = 0
    /// 是否为占位
    var isPlaceholder: Bool = false
    /// 是否可以被选中
    var selectable: Bool = false
    
    init(asset: PHAsset, videoPickable: Bool) {
        super.init()
        self.asset = asset
        self.picked = false
        self.number = 0
        switch asset.mediaType {
        case .audio:
            self.selectable = false
        case .unknown:
            self.selectable = false
        case .image:
            self.selectable = true
            
        case .video:
            if videoPickable {
                self.selectable = true
            } else {
                self.selectable = false
            }
        }
    }
}

extension AssetModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let model: AssetModel = self
        return model
    }
}

// MARK: - 相册Model
class AlbumModel: NSObject {
    /// 相册名称
    var albumName: String = ""
    /// 选中状态
    var isSelected: Bool = false
    /// 结果
    var result: PHFetchResult<AnyObject>?
    /// 资源数组
    var assetArray:[AssetModel]?
}

// MARK: - 相册权限
enum PhotoSeletor_AuthorizationStatus {
    case NotDetermined
    case Restricted
    case Denied
    case Authorized
}

// MARK: - 选择管理器
class WDPhotoSelectorManager: NSObject {
    static let defaultManager = WDPhotoSelectorManager()

    /// 系统自带相册
    private var _smartAlbums:PHFetchResult<PHAssetCollection>?
    public var smartAlbums:PHFetchResult<PHAssetCollection> {
        get {
            if !(_smartAlbums != nil) {
                _smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            }
            return _smartAlbums!
        }
    }
    
    /// 其他app相册或用户创建的相册
    private var _userCollections:PHFetchResult<PHCollection>?
    public var userCollections:PHFetchResult<PHCollection> {
         get {
            if !(_userCollections != nil) {
                _userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            }
            return _userCollections!
        }
    }
    
    /// 申请权限
    ///
    /// - Parameter completion: 权限回调
    func handleAuthorization(completion: @escaping ((PhotoSeletor_AuthorizationStatus)->(Void))) {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    completion(PhotoSeletor_AuthorizationStatus.Authorized)
                case .denied:
                    completion(PhotoSeletor_AuthorizationStatus.Denied)
                case .notDetermined:
                    completion(PhotoSeletor_AuthorizationStatus.NotDetermined)
                case .restricted:
                    completion(PhotoSeletor_AuthorizationStatus.Restricted)
                }
                
            }
        }
    }
    
    /// 获取相册数组
    ///
    /// - Parameters:
    ///   - allowPickingVideo: 是否允许选择视频
    ///   - completion: 成功回调
    func getAllAlbums(allowPickingVideo: Bool, completion:@escaping ((Array<AlbumModel>)->(Void))) {
        var albumArray = Array<AlbumModel>()
        let option = PHFetchOptions.init()
        if !allowPickingVideo {
            option.predicate = NSPredicate.init(format: "mediaType == 1", argumentArray: nil)
        }
        
        option.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        
        smartAlbums.enumerateObjects { (obj, idx, stop) in
            let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: obj, options: option)
            if fetchResult.count > 0 {
                if obj.localizedTitle == "所有照片" || obj.localizedTitle == "All Photo" {
                    albumArray.insert(self.model(result: fetchResult as! PHFetchResult<AnyObject>, name: obj.localizedTitle!, videoPickable: allowPickingVideo), at: 0)
                } else {
                    albumArray.append(self.model(result: fetchResult as! PHFetchResult<AnyObject>, name: obj.localizedTitle!, videoPickable: allowPickingVideo))
                }
            }
        }

        userCollections.enumerateObjects { (obj, idx, stop) in
            let collection: PHAssetCollection = obj as! PHAssetCollection
            let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: collection, options: option)
            if fetchResult.count > 0 {
                albumArray.append(self.model(result: fetchResult as! PHFetchResult<AnyObject>, name: obj.localizedTitle!, videoPickable: allowPickingVideo))
            }
        }
        
        completion(albumArray)
    }
    
    /// 获取image
    ///
    /// - Parameters:
    ///   - model: AlbumModel
    ///   - completion: 回调
    func getPostImage(model: AlbumModel, completion: @escaping ((UIImage)->(Void))){
        getPhoto(asset: (model.result?.firstObject)! as! PHAsset , photoWidth: 60) { (image, info) -> (Void) in
            completion(image)
        }
    }
    
    /// 获取图片
    ///
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - completion: 回调
    func getPhoto(asset: PHAsset, completion: @escaping (Any, Dictionary<AnyHashable, Any>)-> Void) {
        if #available(iOS 11.0, *) {
            if asset.playbackStyle ==  PHAsset.PlaybackStyle.imageAnimated {
                getData(asset: asset, completion: completion)
                return
            }
        }
        getPhoto(asset: asset, photoWidth: UIScreen.main.bounds.width, completion: completion)
    }
    
    
    /// 获取data
    ///
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - completion: 回调
    func getData(asset: PHAsset, completion: @escaping (Any, Dictionary<AnyHashable, Any>)-> Void) {
        PHImageManager.default().requestImageData(for: asset, options: nil) { (data, name, orientation, info) in
            completion(data as Any, info!)
        }
    }
    
    /// 获取图片
    ///
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - photoWidth: 图片宽度
    ///   - completion: 回调
    func getPhoto(asset: PHAsset, photoWidth: CGFloat, completion:@escaping (UIImage, Dictionary<AnyHashable, Any>)->(Void)) {
        let aspectRatio: CGFloat = CGFloat(asset.pixelWidth / asset.pixelHeight);
        let multiple: CGFloat = UIScreen.main.scale
        let pixelWidth: CGFloat = photoWidth * multiple
        let pixelHeight: CGFloat = pixelWidth / aspectRatio
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: pixelWidth, height: pixelHeight), contentMode: .aspectFit, options: nil) { (image, info) in
            if let dic = info {
                completion(image!, dic)
            }
        }
    }
    
    /// 获取视频
    ///
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - completion: 回调
    func getVideo(asset: PHAsset, completion: @escaping (AVPlayerItem, Dictionary<AnyHashable, Any>) -> Void) {
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: nil) { (item, info) in
            completion(item!, info!)
        }
    }
    
    
    /// 获取相册model
    ///
    /// - Parameters:
    ///   - result: PHFetchResult
    ///   - name: 相册名称
    ///   - videoPickable: 是否可以选择视频
    /// - Returns: AlbumModel
    private func model(result: PHFetchResult<AnyObject>, name: String, videoPickable: Bool) -> AlbumModel {
        let model = AlbumModel.init()
        model.result = result
        model.albumName = name
        
        var assetArray:[AssetModel] = Array()
        result.enumerateObjects { (asset, index, stop) in
            assetArray.append(AssetModel.init(asset: asset as! PHAsset, videoPickable: videoPickable))
        }
        model.assetArray = assetArray
        return model;
    }
    
    private var photoLibraryChangedBlock: (() -> (Void))?
    public func photoLibraryChanged(block: @escaping (() -> Void)) {
        photoLibraryChangedBlock = block
    }

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension WDPhotoSelectorManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        photoLibraryChangedBlock!()
    }
}










