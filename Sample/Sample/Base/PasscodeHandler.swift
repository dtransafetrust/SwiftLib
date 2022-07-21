//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

extension UIViewController {
    
    @objc func checkToShowPasscode() {
        checkAndVerifyPasscode(then:{})
    }
    
    func checkAndVerifyPasscode(then: @escaping () -> Void) {
        switch getPasscodeState() {
            case .none:
                then()
                
            case .passcode, .passcode_or_bio:
                inputAndVerifyPassCode {
                    // verified
                    then()
                }
        }
    }
    
    func setPasscodeState(_ passcodeState: PasscodeModel.PasscodeState) {
        let defaults = UserDefaults.standard
        
        defaults.set(passcodeState.index(), forKey: SWDKConstant.SAVE_PASSCODE_STATE)
    }
    
    func getPasscodeState() -> PasscodeModel.PasscodeState {
        let defaults = UserDefaults.standard
        let passcodeIndex = defaults.integer(forKey: SWDKConstant.SAVE_PASSCODE_STATE)
        
        return PasscodeModel.PasscodeState.from(index: passcodeIndex)
    }
    
    func showInputDialog(passcodeEntered: @escaping (String) -> Void) {
        let dialog = DialogUtils.buildInputDialog(title: SWDKConstant.PASSCODE_REQUIRE_MESSAGE,
                                                  positiveButton: SWDKConstant.btnDone,
                                                  negativeButton: SWDKConstant.btnCancel,
                                                  messagePlaceHolder: SWDKConstant.INPUT_PASSCODE_MESSAGE) { (passcode) in
            if (passcode == nil) {
                self.showInputDialog(passcodeEntered: passcodeEntered)
                return
            }
            passcodeEntered(passcode!)
        }
        let input = dialog.textFields?[0]
        input?.placeholder = "******"
        input?.keyboardType = UIKeyboardType.numberPad
        input?.isSecureTextEntry = true
        self.present(dialog, animated: true, completion: nil)
    }
    
    // MARK: - Private methods

    private func inputAndVerifyPassCode(verified: @escaping () -> Void) {
        showInputDialog { (passcode) in
            SWDK.sharedInstance().configurationService().verifyPasscode(passcode: passcode, completion: { (isVerified, error) in
                if(error != nil) {
                    // show verify input again
                    self.inputAndVerifyPassCode(verified: verified)
                    return
                }
                verified()
            })
        }
    }

    private func isRequiredPasscode() -> Bool {
        return try! SWDK.sharedInstance().configurationService().isRequiredPasscode()
    }
}
