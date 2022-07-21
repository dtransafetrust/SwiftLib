//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit

extension LoginViewController {

    func showCountryCodeFixingDialog(phoneNumber: String, phoneFixingResult: @escaping (String) -> Void) {
        let dialog = DialogUtils.buildInputDialog(title: SWDKConstant.AREA_CODE_REQUIRE_MESSAGE,
                                                  positiveButton: SWDKConstant.btnDone,
                                                  negativeButton: SWDKConstant.btnCancel,
                                                  messagePlaceHolder: SWDKConstant.INPUT_ACREA_CODE_MESSAGE) { (areaCode) in
            if (areaCode == nil || areaCode!.replacingOccurrences(of: "+", with: "").isEmpty) {
                return
            }
            let fixedNumber = "+\(areaCode!.replacingOccurrences(of: "+", with: ""))\(phoneNumber.suffix(9))"
            phoneFixingResult(fixedNumber)
        }
        let input = dialog.textFields?[0]
        input?.keyboardType = UIKeyboardType.phonePad
        input?.text = "+"
        self.present(dialog, animated: true, completion: nil)
    }

    func showAccountNotFoundErrorDialog() {
        let alert = UIAlertController(title: nil, message: SWDKConstant.USERNAME_PASSWORD_INVALID_MESSAGE, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: SWDKConstant.btnOk, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
