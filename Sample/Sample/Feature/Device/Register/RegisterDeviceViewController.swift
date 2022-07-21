//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class RegisterDeviceViewController: BaseUIViewController {

    private var email: String? = ""
    private var password: String? = ""
    private var accountId: String? = ""
    private var registerResultCallback: ((String?, ErrorDetail?) -> Void)?
    private var loginType: AuthenticationType = .emailOrMobileNumber

    private let authenticationService = SWDK.sharedInstance().authenticationService();

    func setup(email: String, password: String, accountId: String, loginType: AuthenticationType,
        registerResultCallback: @escaping (String?, ErrorDetail?) -> Void) {
        self.email = email
        self.password = password
        self.accountId = accountId
        self.loginType = loginType
        self.registerResultCallback = registerResultCallback
    }

    override func viewDidLoad() {
        registerDevice(email: email!, password: password!, accountId: accountId!)
    }

    private func registerDevice(email: String, password: String, accountId: String) {
        print("\n========= start register device ====\n")
        showProgressDialog()
        authenticationService.registerDevice(
            userIdentifier: email,
            password: password,
            type: loginType) { (account, error) in
            self.hideProgressDialog()
            if (error != nil) {
                self.dismiss(animated: false, completion: nil)
                self.registerResultCallback?(nil, error)
                return;
            }
            
            if(account?.isByPassActive == true) {
                self.registerResultCallback?(account?.id,nil)
                return
            } // if
            self.showInputPinCode(acountId: account!.id)
        }
    }

    private func showInputPinCode(acountId: String) {
        let dialog = DialogUtils.buildInputDialog(
            title: SWDKConstant.ACTIVE_CODE,
            positiveButton: SWDKConstant.btnOk,
            negativeButton: SWDKConstant.btnCancel,
            messagePlaceHolder: SWDKConstant.ACTIVE_CODE_MESSAGE_PLACE_HOLDER) { (String) in
            if (String == nil || String!.isEmpty) {
                self.dismiss(animated: false, completion: nil)
                return
            }
            self.activateDevice(acountId: acountId, pin: String!)
        }
        let input = dialog.textFields?[0]
        input?.keyboardType = UIKeyboardType.numberPad
        self.present(dialog, animated: true, completion: nil)
    }

    private func activateDevice(acountId: String, pin: String) {
        showProgressDialog()
        authenticationService.activateDevice(accountId: acountId, pin: pin) { (accountId, error) in
            self.hideProgressDialog()
            self.dismiss(animated: false, completion: nil)
            self.registerResultCallback?(accountId, error)
        }
    }
}
