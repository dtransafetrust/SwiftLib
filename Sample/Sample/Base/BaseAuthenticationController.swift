//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class BaseAuthenticationController: BaseUIViewController {

    public let loginModel = LoginModel()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is OrganizationSelectionViewController) { // TrustIssuerNotUse
            let organizationListController = (segue.destination as! OrganizationSelectionViewController) // TrustIssuerNotUse
            organizationListController.data = loginModel.organizations // TrustIssuerNotUse
            organizationListController.accountId = loginModel.accountId // TrustIssuerNotUse
        } // TrustIssuerNotUse
    }

    func loadOrganizationList(accountId: String) { // TrustIssuerNotUse
        print("======  start loadOrganizationList  ======     \(accountId)") // TrustIssuerNotUse
        checkAndVerifyPasscode { // TrustIssuerNotUse
            self.showProgressDialog() // TrustIssuerNotUse
            self.loginModel.loadOrganizationList(id: accountId) { (organizations, error) in // TrustIssuerNotUse
                self.hideProgressDialog() // TrustIssuerNotUse
                if (error != nil) { // TrustIssuerNotUse
                    self.showErrorDialog(message: error!.message) // TrustIssuerNotUse
                    return; // TrustIssuerNotUse
                } // TrustIssuerNotUse
                self.performSegue(withIdentifier: "show_organization_selection", sender: nil) // TrustIssuerNotUse
            } // TrustIssuerNotUse
        } // TrustIssuerNotUse
    } // TrustIssuerNotUse

    func activateAccount(email: String, password: String, pin: String) { // TrustIssuerNotUse
        showProgressDialog() // TrustIssuerNotUse
        let authenticationService = SWDK.sharedInstance().authenticationService(); // TrustIssuerNotUse
        authenticationService.activateAccount(userIdentifier: email, password: password, pin: pin) { accountId, error in // TrustIssuerNotUse
            self.hideProgressDialog() // TrustIssuerNotUse
            self.handleActivationResult(accountId: accountId, error: error) // TrustIssuerNotUse
        } // TrustIssuerNotUse
    } // TrustIssuerNotUse
    
    func handleActivationResult(accountId: String?, error: ErrorDetail?) {
        if (error != nil) {
            switch SWDKErrorCode.init(rawValue: Int32(error!.code)!)! {
            case SWDKErrorCode.PASSCODE_EMPTY:
                self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_PASSWORD_EMPTY)
                break;
            case SWDKErrorCode.PASSCODE_LENGTH_INVALID:
                self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_PASSWORD_LENGTH)
                break;
            case SWDKErrorCode.PASSCODE_MIXED_CASE_INVALID:
                self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_MIXED_CASE)
                break;
            case SWDKErrorCode.PASSCODE_NUMERIC_CHARACTER_INVALID:
                self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_NUMBER_CHARACTER)
                break;
            case SWDKErrorCode.PASSCODE_SPECIAL_SYMBOL_INVALID:
                self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_SPECIAL_CHARACTER)
                break;
            case SWDKErrorCode.PASSCODE_GENERAL_ERROR:
                self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_GENERGAL)
                break;
            default:
                self.showErrorDialog(message: error!.message)
            }
            return;
        }
        loginModel.accountId = accountId! // TrustIssuerNotUse
        loadOrganizationList(accountId: accountId!) // TrustIssuerNotUse
    }
    
}
