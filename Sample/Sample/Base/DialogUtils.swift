//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//


import UIKit

extension UIView {

    func showDialogSingleButton(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: SWDKConstant.btnOk, style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
}

class DialogUtils {

    private static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    private static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    private static var pickerDialogDataSouceInstance: LocalDataSource? = nil


    static func buildConfirmDialog(title: String,
        positiveButton: String,
        negativeButton: String,
        firstInputPlaceHolder: String,
        nextInputPlaceHolder: String,
        handleResult: @escaping (String?, String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: negativeButton,
            style: .cancel))
        alert.addAction(UIAlertAction(title: positiveButton,
            style: .default,
            handler: { action in
                let firtInputData = alert.textFields?.first?.text
                let nextInputData = alert.textFields?.last?.text
                handleResult(firtInputData, nextInputData)
            }))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = firstInputPlaceHolder
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = nextInputPlaceHolder
        })
        return alert
    }

    static func buildInputDialog(title: String,
        positiveButton: String,
        negativeButton: String,
        messagePlaceHolder: String,
        handleResult: @escaping (String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: negativeButton,
            style: .cancel,
            handler: { action in
                handleResult(nil)
            }))
        alert.addAction(UIAlertAction(title: positiveButton,
            style: .default,
            handler: { action in
                if let inputData = alert.textFields?.first?.text {
                    handleResult(inputData)
                }
            }))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = messagePlaceHolder
        })
        return alert
    }

    static func buildPrickerDialog(title: String,
                                   positiveButton: String,
                                   negativeButton: String,
                                   selections: Array<String>,
                                   selectionIndex: Int,
                                   handleResult: @escaping (Int) -> Void) -> UIAlertController {
        let dialog = DialogUtils.buildPrickerDialog(title: title,
                                                    positiveButton: positiveButton,
                                                    negativeButton: negativeButton,
                                                    selections: selections,
                                                    selectionIndex: selectionIndex,
                                                    alertHeight: 0,
                                                    pickerRect: CGRect.zero,
                                                    handleResult: handleResult)
        
        return dialog
    }
    
    static func buildPrickerDialog(title: String,
                                   positiveButton: String,
                                   negativeButton: String,
                                   selections: Array<String>,
                                   selectionIndex: Int,
                                   alertHeight: CGFloat,
                                   pickerRect: CGRect,
                                   handleResult: @escaping (Int) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: "\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        
        let pickerView = UIPickerView(frame: pickerRect)
        if pickerRect == CGRect.zero {
            pickerView.frame = CGRect(x: 5, y: 20, width: 250, height: 140)
        }
        
        alert.view.addSubview(pickerView)
        pickerDialogDataSouceInstance = LocalDataSource(data: selections)
        pickerView.dataSource = pickerDialogDataSouceInstance
        pickerView.delegate = pickerDialogDataSouceInstance
        alert.addAction(UIAlertAction(title: positiveButton, style: .default, handler: { (UIAlertAction) in
            handleResult(pickerView.selectedRow(inComponent: 0))
        }))
        if(!negativeButton.isEmpty) {
            alert.addAction(UIAlertAction(title: negativeButton,
                                          style: .cancel,
                                          handler: { action in
                                            handleResult(selectionIndex)
                                          }))
        }
        pickerView.selectRow(selectionIndex, inComponent: 0, animated: true)
        
        // Change alert height
        if alertHeight != 0 {
            let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view,
                                                               attribute: NSLayoutConstraint.Attribute.height,
                                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                                               toItem: nil,
                                                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                               multiplier: 1,
                                                               constant: alertHeight)
            alert.view.addConstraint(height)
        }
        
        return alert
    }

    private class LocalDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

        private var mData: Array<String>? = nil

        init(data: Array<String>) {
            self.mData = data
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return mData!.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            let value = mData![row]
            return value
        }
    }
    
    static func showDialogSingleButton(controller: UIViewController,
                                       title: String,
                                       message: String,
                                       handleResult: @escaping () -> Void) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // set font for aler title
        let titleFontName: String = UIFont.BaseFontName.getStringWith(UIFont.BaseFontName.FONT_NAME_1_BOLD.rawValue)
        let titleFont = [NSAttributedString.Key.font: UIFont(name: titleFontName, size: SWDKConstant.ERROR_TITLE_SIZE)!]
        let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont)
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        // --
        
        // set font for alert message
        let messageFontName: String = UIFont.BaseFontName.getStringWith(UIFont.BaseFontName.FONT_NAME_1_REGULAR.rawValue)
        let messageFont = [NSAttributedString.Key.font: UIFont(name: messageFontName, size: SWDKConstant.ERROR_MESSAGE_SIZE)!]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        // --
        
        let positiveAlertAction = UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: { action in
            handleResult()
        })
        positiveAlertAction.setValue(SafeTrustColor.PRIMARY_COLOR, forKey: "titleTextColor")
        alert.addAction(positiveAlertAction)
        
        controller.present(alert, animated: true)
        
        return alert
    }
    
    static func showDialogDoubleButton(controller: UIViewController,
                                       title: String,
                                       message: String,
                                       handleResult: @escaping (Bool) -> Void) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // set font for aler title
        let titleFontName: String = UIFont.BaseFontName.getStringWith(UIFont.BaseFontName.FONT_NAME_1_BOLD.rawValue)
        let titleFont = [NSAttributedString.Key.font: UIFont(name: titleFontName, size: SWDKConstant.ERROR_TITLE_SIZE)!]
        let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont)
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        // --
        
        // set font for alert message
        let messageFontName: String = UIFont.BaseFontName.getStringWith(UIFont.BaseFontName.FONT_NAME_1_REGULAR.rawValue)
        let messageFont = [NSAttributedString.Key.font: UIFont(name: messageFontName, size: SWDKConstant.ERROR_MESSAGE_SIZE)!]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        // --
        
        let positiveAlertAction = UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: { action in
            handleResult(true)
        })
        positiveAlertAction.setValue(SafeTrustColor.PRIMARY_COLOR, forKey: "titleTextColor")
        alert.addAction(positiveAlertAction)
        
        let negativeAlerAction = UIAlertAction(title: NSLocalizedString("BUTTON_CANCEL", comment: ""), style: .cancel, handler: { action in
            handleResult(false)
        })
        negativeAlerAction.setValue(SafeTrustColor.PRIMARY_COLOR, forKey: "titleTextColor")
        alert.addAction(negativeAlerAction)
        
        controller.present(alert, animated: true)
        
        return alert
    }
    
    static func showBaseDialog(controller: UIViewController,
                               title: String,
                               message: String,
                               positiveButton: String,
                               negativeButton: String,
                               handleResult: @escaping (Bool) -> Void) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: negativeButton, style: .cancel, handler: {
            action in
            handleResult(false)
        }))
        alert.addAction(UIAlertAction(title: positiveButton, style: .default, handler: {
            action in
            handleResult(true)
        }))
        
        controller.present(alert, animated: true)
        
        return alert
    }
}
