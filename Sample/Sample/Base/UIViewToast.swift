//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import Foundation
import UIKit
import UIKit.UITextField

func /(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs / CGFloat(rhs)
}

let HRToastDefaultDuration = 3.0
let HRToastFadeDuration = 0.2
let HRToastHorizontalMargin: CGFloat = 10.0
let HRToastVerticalMargin: CGFloat = 10.0

let HRToastPositionDefault = "bottom"
let HRToastPositionTop = "top"
let HRToastPositionCenter = "center"

// activity
let HRToastActivityWidth: CGFloat = 100.0
let HRToastActivityHeight: CGFloat = 100.0
let HRToastActivityPositionDefault = "center"

// image size
let HRToastImageViewWidth: CGFloat = 80.0
let HRToastImageViewHeight: CGFloat = 80.0

// label setting
let HRToastMaxWidth: CGFloat = 0.8; // 80% of parent view width
let HRToastMaxHeight: CGFloat = 0.8;
let HRToastFontSize: CGFloat = 16.0
let HRToastMaxTitleLines = 0
let HRToastMaxMessageLines = 0

// shadow appearance
let HRToastShadowOpacity: CGFloat = 0.8
let HRToastShadowRadius: CGFloat = 6.0
let HRToastShadowOffset: CGSize = CGSize(width: 4.0, height: 4.0)

let HRToastOpacity: CGFloat = 0.5
let HRToastCornerRadius: CGFloat = 10.0

var HRToastActivityView: UnsafePointer<UIView>?
var HRToastTimer: UnsafePointer<Timer>?
var HRToastView: UnsafePointer<UIView>?


// Color Scheme
let HRAppColor: UIColor = UIColor.black//UIappViewController().appUIColor
let HRAppColor_2: UIColor = UIColor.white


let HRToastHidesOnTap = true
let HRToastDisplayShadow = false

//HRToast (UIView + Toast using Swift)

extension UIView {

    //public methods
    func showToast(message msg: String) {
        self.makeToast(message: msg, duration: HRToastDefaultDuration, position: HRToastPositionDefault as AnyObject)
    }

    func makeToast(message msg: String, duration: Double, position: AnyObject) {
        let toast = self.viewForMessage(msg: msg, title: nil, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }

    func showToast(toast: UIView, duration: Double, position: AnyObject) {
        let existToast = objc_getAssociatedObject(self, &HRToastView) as! UIView?
        if existToast != nil {
            if let timer: Timer = objc_getAssociatedObject(existToast!, &HRToastTimer) as? Timer {
                timer.invalidate();
            }
            self.hideToast(toast: existToast!, force: false);
        }

        toast.center = self.centerPointForPosition(position: position, toast: toast)
        toast.alpha = 0.0

        if HRToastHidesOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: toast, action: #selector(handleToastTapped(recognizer:)))
            toast.addGestureRecognizer(tapRecognizer)
            toast.isUserInteractionEnabled = true;
            toast.isExclusiveTouch = true;
        }

        self.addSubview(toast)
        objc_setAssociatedObject(self, &HRToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

        UIView.animate(withDuration: HRToastFadeDuration,
                delay: 0.0, options: ([.curveEaseOut, .allowUserInteraction]),
                animations: {
                    toast.alpha = 1.0
                },
                completion: { (finished: Bool) in
                    let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.toastTimerDidFinish(timer:)), userInfo: toast, repeats: false)
                    objc_setAssociatedObject(toast, &HRToastTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                })
    }

    func hideToastActivity() {
        self.isUserInteractionEnabled = true
        let existingActivityView = objc_getAssociatedObject(self, &HRToastActivityView) as! UIView?
        if existingActivityView == nil {
            return
        }
        UIView.animate(withDuration: HRToastFadeDuration,
                delay: 0.0,
                options: UIView.AnimationOptions.curveEaseOut,
                animations: {
                    existingActivityView!.alpha = 0.0
                },
                completion: { (finished: Bool) in
                    existingActivityView!.removeFromSuperview()
                    objc_setAssociatedObject(self, &HRToastActivityView, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                })
    }

    /*
     *  private methods (helper)
     */
    func hideToast(toast: UIView) {
        self.isUserInteractionEnabled = true
        self.hideToast(toast: toast, force: false);
    }

    func hideToast(toast: UIView, force: Bool) {
        let completeClosure = { (finish: Bool) -> () in
            toast.removeFromSuperview()
            objc_setAssociatedObject(self, &HRToastTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        if force {
            completeClosure(true)
        } else {
            UIView.animate(withDuration: HRToastFadeDuration,
                    delay: 0.0,
                    options: ([.curveEaseIn, .beginFromCurrentState]),
                    animations: {
                        toast.alpha = 0.0
                    },
                    completion: completeClosure)
        }
    }

    @objc func toastTimerDidFinish(timer: Timer) {
        self.hideToast(toast: timer.userInfo as! UIView)
    }

    @objc func handleToastTapped(recognizer: UITapGestureRecognizer) {

        // var timer = objc_getAssociatedObject(self, &HRToastTimer) as! NSTimer
        // timer.invalidate()

        self.hideToast(toast: recognizer.view!)
    }

    func centerPointForPosition(position: AnyObject, toast: UIView) -> CGPoint {
        if position is String {
            let toastSize = toast.bounds.size
            let viewSize = self.bounds.size
            if position.lowercased == HRToastPositionTop {
                return CGPoint(x: viewSize.width / 2, y: toastSize.height / 2 + HRToastVerticalMargin)

            } else if position.lowercased == HRToastPositionDefault {
                return CGPoint(x: viewSize.width / 2, y: viewSize.height - toastSize.height - 15 - HRToastVerticalMargin)
            } else if position.lowercased == HRToastPositionCenter {
                return CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
            }
        } else if position is NSValue {
            return position.cgPointValue
        }

        print("Warning: Invalid position for toast.")
        return self.centerPointForPosition(position: HRToastPositionDefault as AnyObject, toast: toast)
    }

    func viewForMessage(msg: String?, title: String?, image: UIImage?) -> UIView? {
        if msg == nil && title == nil && image == nil {
            return nil
        }

        var msgLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?

        let wrapperView = UIView()
        wrapperView.autoresizingMask = ([.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin])
        wrapperView.layer.cornerRadius = HRToastCornerRadius
        wrapperView.backgroundColor = UIColor.black.withAlphaComponent(HRToastOpacity)

        if HRToastDisplayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = Float(HRToastShadowOpacity)
            wrapperView.layer.shadowRadius = HRToastShadowRadius
            wrapperView.layer.shadowOffset = HRToastShadowOffset
        }

        if image != nil {
            imageView = UIImageView(image: image)
            imageView!.contentMode = .scaleAspectFit
            imageView!.frame = CGRect(x: HRToastHorizontalMargin, y: HRToastVerticalMargin, width: CGFloat(HRToastImageViewWidth), height: CGFloat(HRToastImageViewHeight))
        }

        var imageWidth: CGFloat, imageHeight: CGFloat, imageLeft: CGFloat
        if imageView != nil {
            imageWidth = imageView!.bounds.size.width
            imageHeight = imageView!.bounds.size.height
            imageLeft = HRToastHorizontalMargin
        } else {
            imageWidth = 0.0;
            imageHeight = 0.0;
            imageLeft = 0.0
        }

        if title != nil {
            titleLabel = UILabel()
            titleLabel!.numberOfLines = HRToastMaxTitleLines
            titleLabel!.font = UIFont.boldSystemFont(ofSize: HRToastFontSize)
            titleLabel!.textAlignment = .center
            titleLabel!.lineBreakMode = .byWordWrapping
            titleLabel!.textColor = UIColor.white
            titleLabel!.backgroundColor = UIColor.clear
            titleLabel!.alpha = 1.0
            titleLabel!.text = title

            // size the title label according to the length of the text

            let maxSizeTitle = CGSize(width: (self.bounds.size.width * HRToastMaxWidth) - imageWidth, height: self.bounds.size.height * HRToastMaxHeight)

            let expectedHeight = title!.stringHeightWithFontSize(fontSize: HRToastFontSize, width: maxSizeTitle.width)
            titleLabel!.frame = CGRect(x: 0.0, y: 0.0, width: maxSizeTitle.width, height: expectedHeight)
        }

        if msg != nil {
            msgLabel = UILabel();
            msgLabel!.numberOfLines = HRToastMaxMessageLines
            msgLabel!.font = UIFont.systemFont(ofSize: HRToastFontSize)
            msgLabel!.lineBreakMode = .byWordWrapping
            msgLabel!.textAlignment = .center
            msgLabel!.textColor = UIColor.white
            msgLabel!.backgroundColor = UIColor.clear
            msgLabel!.alpha = 1.0
            msgLabel!.text = msg


            let maxSizeMessage = CGSize(width: (self.bounds.size.width * HRToastMaxWidth) - imageWidth, height: self.bounds.size.height * HRToastMaxHeight)
            let expectedHeight = msg!.stringHeightWithFontSize(fontSize: HRToastFontSize, width: maxSizeMessage.width)
            msgLabel!.frame = CGRect(x: 0.0, y: 0.0, width: maxSizeMessage.width, height: expectedHeight)
        }

        var titleWidth: CGFloat, titleHeight: CGFloat, titleTop: CGFloat, titleLeft: CGFloat
        if titleLabel != nil {
            titleWidth = titleLabel!.bounds.size.width
            titleHeight = titleLabel!.bounds.size.height
            titleTop = HRToastVerticalMargin
            titleLeft = imageLeft + imageWidth + HRToastHorizontalMargin
        } else {
            titleWidth = 0.0;
            titleHeight = 0.0;
            titleTop = 0.0;
            titleLeft = 0.0
        }

        var msgWidth: CGFloat, msgHeight: CGFloat, msgTop: CGFloat, msgLeft: CGFloat
        if msgLabel != nil {
            msgWidth = msgLabel!.bounds.size.width
            msgHeight = msgLabel!.bounds.size.height
            msgTop = titleTop + titleHeight + HRToastVerticalMargin
            msgLeft = imageLeft + imageWidth + HRToastHorizontalMargin
        } else {
            msgWidth = 0.0;
            msgHeight = 0.0;
            msgTop = 0.0;
            msgLeft = 0.0
        }

        let largerWidth = max(titleWidth, msgWidth)
        let largerLeft = max(titleLeft, msgLeft)

        // set wrapper view's frame
        let wrapperWidth = max(imageWidth + HRToastHorizontalMargin * 2, largerLeft + largerWidth + HRToastHorizontalMargin)
        let wrapperHeight = max(msgTop + msgHeight + HRToastVerticalMargin, imageHeight + HRToastVerticalMargin * 2)
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)

        // add subviews
        if titleLabel != nil {
            titleLabel!.frame = CGRect(x: titleLeft, y: titleTop, width: titleWidth, height: titleHeight)
            wrapperView.addSubview(titleLabel!)
        }
        if msgLabel != nil {
            msgLabel!.frame = CGRect(x: msgLeft, y: msgTop, width: msgWidth, height: msgHeight)
            wrapperView.addSubview(msgLabel!)
        }
        if imageView != nil {
            wrapperView.addSubview(imageView!)
        }

        return wrapperView
    }

}

extension String {

    func stringHeightWithFontSize(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.paragraphStyle: paragraphStyle.copy()]

        let text = self as NSString
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.size.height
    }
}

extension UITextField {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text!)
    }
}
