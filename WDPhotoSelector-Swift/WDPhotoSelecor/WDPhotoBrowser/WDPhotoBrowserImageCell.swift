//
//  WDPhotoBrowserImageCell.swift
//  WDPhotoSelector-Swift
//
//  Created by wudan on 2019/4/20.
//  Copyright © 2019 com.wudan. All rights reserved.
//

import UIKit
import FLAnimatedImage
import AVFoundation

protocol WDPhotoBrowserImageCellDelegate {
    func browserImageCellDidRecognizedSingleGuesture(cell: WDPhotoBrowserImageCell)
    func browserImageCellDidRecognizedPanGuestureChange(cell: WDPhotoBrowserImageCell, percentScale: CGFloat)
    func browserImageCellDidRecognizedPanGuestureFinished(cell: WDPhotoBrowserImageCell)
}

class WDPhotoBrowserImageCell: UICollectionViewCell{
    
    var delegate: WDPhotoBrowserImageCellDelegate?
    var firstTouchPoint: CGPoint = .zero
    
    private let scrollView: UIScrollView = {
        let s = UIScrollView.init(frame: cSCREEN_BOUNDS)
        s.showsVerticalScrollIndicator = false
        s.showsHorizontalScrollIndicator = false
        s.backgroundColor = .clear
        s.minimumZoomScale = 1.0
        s.maximumZoomScale = 4.0;
        s.bouncesZoom = true
        return s
    }()
    
    public let imageView: FLAnimatedImageView = {
        let i = FLAnimatedImageView.init()
        i.contentMode = .scaleAspectFill
        i.clipsToBounds = true
        return i
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.addSubview(imageView)
    }
    
    func addTapGuesture() {
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(didRecognizedDoubleTap(sender:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let singleGuesture = UITapGestureRecognizer.init(target: self, action: #selector(didRecognizedSingleGuesture(sender:)))
        singleGuesture.numberOfTapsRequired = 1
        singleGuesture.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(singleGuesture)
        
        let panGusture = UIPanGestureRecognizer.init(target: self, action: #selector(didRecognizedPanGuesture(pan:)))
        panGusture.delegate = self
        if !(scrollView.gestureRecognizers?.contains(panGusture))! {
            scrollView.addGestureRecognizer(panGusture)
        }
    }
    
    @objc func didRecognizedSingleGuesture(sender: UITapGestureRecognizer) {
        scrollView.zoomScale = 1
        delegate?.browserImageCellDidRecognizedSingleGuesture(cell: self)
    }
    
    @objc func didRecognizedDoubleTap(sender: UITapGestureRecognizer) {
        var newScale = scrollView.zoomScale
        if newScale == scrollView.minimumZoomScale {
            newScale = scrollView.maximumZoomScale / 2
        } else {
            newScale = scrollView.minimumZoomScale
        }
        
        let zoomRect = zoomRectScale(for: newScale, center: sender.location(in: sender.view))
        scrollView.zoom(to: zoomRect, animated: true)
    }
    
    private func zoomRectScale(for scale: CGFloat, center: CGPoint) -> CGRect {
        let size: CGSize = CGSize(width: scrollView.bounds.width / scale, height: scrollView.bounds.height / scale)
        let rect: CGRect = CGRect(x: center.x - (size.width / 2.0), y: center.y - (size.height / 2.0), width: size.width, height: size.height)
        return rect
    }
    
    @objc func didRecognizedPanGuesture(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: window)
        let point = pan.translation(in: window)
        var scale = 1.0 - abs(translation.y) / cSCREEN_HEIGHT
        switch pan.state {
        case .began: break
        case .changed:
            scale = max(scale, 0)
            let s: CGFloat = max(scale, 0.5)
            let translation = CGAffineTransform(translationX: point.x / s, y: point.y / s)
            let translationScale = CGAffineTransform(scaleX: s, y: s)
            imageView.transform = translation.concatenating(translation)
            imageView.transform = translation.concatenating(translationScale)
            delegate?.browserImageCellDidRecognizedPanGuestureChange(cell: self, percentScale: scale)
        case .ended:
            UIView.animate(withDuration: 0.5) {
                self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            delegate?.browserImageCellDidRecognizedPanGuestureChange(cell: self, percentScale: scale)
            if scale < 0.9 {
                delegate?.browserImageCellDidRecognizedPanGuestureFinished(cell: self)
            } else {
                delegate?.browserImageCellDidRecognizedPanGuestureChange(cell: self, percentScale: 1)
            }
        case .cancelled:
            imageView.transform = CGAffineTransform.identity
            delegate?.browserImageCellDidRecognizedPanGuestureChange(cell: self, percentScale: 1)
        case .failed:
            imageView.transform = CGAffineTransform.identity
            delegate?.browserImageCellDidRecognizedPanGuestureChange(cell: self, percentScale: 1)
        case .possible:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var _model: AssetModel?
    
    public func setup(with model: AssetModel) {
        _model = model
        if let asset = model.asset {
            WDPhotoSelectorManager.defaultManager.getPhoto(asset: asset) { (data, info) in
                if let image = data as? UIImage {
                    self.imageView.image = image
                    self.setupImageFrame(image: image)
                } else {
                    let image = FLAnimatedImage.init(animatedGIFData: (data as! Data))
                    self.imageView.animatedImage = image
                    self.setupImageFrame(image: self.imageView.image!)
                }
                self.addTapGuesture()
            }
        }
    }
    
    func setupImageFrame(image: UIImage) {
        let imageW: CGFloat = frame.width
        var rotaion: CGFloat = (image.size.width / (image.size.height > 0 ? image.size.height : imageW))
        if(rotaion <= 0.0){
            rotaion = 1.0
        }
        let imageH:CGFloat = imageW / rotaion
        var originY: CGFloat = 0.0
        if (imageH > contentView.frame.size.height) {
            originY = 0
        } else {
            originY = (contentView.frame.size.height - imageH) / 2.0
        }
        
        let imgViewRect = CGRect(x: 0, y: originY, width: cSCREEN_WIDTH, height: imageH)
        imageView.frame = imgViewRect
        scrollView.contentSize = CGSize(width: imageW, height: imageH)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension WDPhotoBrowserImageCell: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        firstTouchPoint = touch.location(in: window)
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = gestureRecognizer.location(in: window)
        let dirTop = firstTouchPoint.y - touchPoint.y
        if dirTop > -10 && dirTop < 10 {
            return false
        }
        
        let dirLift = firstTouchPoint.x - touchPoint.x
        if dirLift > -10 && dirLift < 10 && imageView.frame.height > UIScreen.main.bounds.height {
            return false
        }
        return true
    }
}

extension WDPhotoBrowserImageCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
    
        let boundsSize: CGSize = bounds.size
        var frameToCenter: CGRect = imageView.frame
        
        if frameToCenter.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        imageView.frame = frameToCenter
    }
}
