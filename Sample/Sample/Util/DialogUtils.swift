//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//


import UIKit

extension UIView {
    
    func showDialogSingleButton(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
    
    func showDialogDoubleButton(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        controller.present(alert, animated: true)
    }
}

class DialogUtils{
    static func buildInputDialog(title: String,
                             positiveButton: String,
                             negativeButton: String,
                             messagePlaceHolder: String,
                             handleResult: @escaping (String?) -> Void) -> UIAlertController{
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
}
