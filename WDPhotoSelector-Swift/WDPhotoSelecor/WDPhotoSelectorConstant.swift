
import Foundation
import UIKit


public let cSCREEN_BOUNDS = UIScreen.main.bounds
public let cSCREEN_SIZE = UIScreen.main.bounds.size
public let cSCREEN_WIDTH = UIScreen.main.bounds.width
public let cSCREEN_RETIO = UIScreen.main.bounds.width / 375.0
public let cSCREEN_HEIGHT = UIScreen.main.bounds.height
public let cNAVIGATIONBAR_HEIGHT = UIApplication.shared.statusBarFrame.height + 44

public let cROW_SECTION_INSTER = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
public let cCOLLECTIONVIEW_RECT = CGRect(x: 0,
                                         y: cNAVIGATIONBAR_HEIGHT,
                                         width: cSCREEN_WIDTH,
                                         height: cSCREEN_HEIGHT - cNAVIGATIONBAR_HEIGHT)

public let cNAVIGATIONBARVIEW_RECT = CGRect(x: 0,
                                            y: 0,
                                            width: cSCREEN_WIDTH,
                                            height: cNAVIGATIONBAR_HEIGHT)

public let cALBUMLISTVIEW_RECT = CGRect(x: 0,
                                        y: cNAVIGATIONBAR_HEIGHT,
                                        width: cSCREEN_WIDTH,
                                        height: 0)

public let cALBUMLISTVIEW_TABLEVIEE_HIEDN_RECT = CGRect(x: 0,
                                                        y: 0,
                                                        width: cSCREEN_WIDTH,
                                                        height: 0)
public let cALBUMLISTVIEW_RECT_SHOW_RECT = CGRect(x: 0,
                                                  y: cNAVIGATIONBAR_HEIGHT,
                                                  width: cSCREEN_WIDTH,
                                                  height: cSCREEN_HEIGHT - cNAVIGATIONBAR_HEIGHT)

public func cCreateImage(by color: UIColor) -> UIImage? {
    let frame = CGRect(x: 0, y: 0, width: 25 * cSCREEN_RETIO, height: 25 * cSCREEN_RETIO)
    UIGraphicsBeginImageContext(frame.size)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fill(frame)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

extension UIButton {
    /// UIButton选择和取消动画
    open func shakeAniamtion() {
        let animationScale1 = self.isSelected ? NSNumber.init(value: 1.15) : NSNumber.init(value: 0.5)
        let animationScale2 = self.isSelected ? NSNumber.init(value: 0.92) : NSNumber.init(value: 1.15)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseOut] , animations: {
            self.layer.setValue(animationScale1, forKeyPath: "transform.scale")
        }) { (finished) in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseOut] , animations: {
                self.layer.setValue(animationScale2, forKeyPath: "transform.scale")
            }) { (finished) in
                UIView.animate(withDuration: 1, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
                    self.layer.setValue( NSNumber.init(value: 1), forKeyPath: "transform.scale")
                }, completion: nil)
            }
        }
    }
}


