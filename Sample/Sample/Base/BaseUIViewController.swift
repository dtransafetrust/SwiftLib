//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class BaseUIViewController: UIViewController {
    private lazy var configurationService = SWDK.sharedInstance().configurationService();
    var indicator: UIActivityIndicatorView? = nil
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    


    override func viewDidAppear(_ animated: Bool) {
        registerErrorReceiver()
        registerEnterBackground()
        registerActiveFromBackground()
    }

    override func viewDidDisappear(_ animated: Bool) {
        unregisterErrorReceiver()
        removeEnterBackground()
        removeActiveFromBackground()
    }
    
    override func enterBackground() {
        checkToShowPasscode()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func progressDialog() {
        let transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator?.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        indicator?.center = view.center
        indicator?.transform = transform
        indicator?.color = .blue
        view.addSubview(indicator!)
        indicator?.bringSubviewToFront(view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func showProgressDialog() {
        progressDialog()
        indicator?.startAnimating()
    }

    func hideProgressDialog() {
        indicator?.stopAnimating()
    }

    func showToastMessage(message: String) {
        self.view.showToast(message: message)
    }

    func showErrorDialog(message: String) {
        let fixedMessage = message.replacingOccurrences(of: "otp", with: "SMS code")
        self.view.showDialogSingleButton(controller: self, title: NSLocalizedString("TITLE_ERROR_DIALOG", comment: ""), message: fixedMessage)
    }
    
    func showErrorDialog(title: String, message: String) {
        let fixedMessage = message.replacingOccurrences(of: "otp", with: "SMS code")
        self.view.showDialogSingleButton(controller: self, title: title, message: fixedMessage)
    }
    
    func showErrorDialog(error: ErrorDetail!) {
        if (error != nil) {
            switch SWDKErrorCode.init(rawValue: Int32(error!.code)!)! {
                
                case SWDKErrorCode.APP_NEEDS_TO_BE_INITIALIZED://12
                    self.showErrorDialog(message: NSLocalizedString("ERROR_APP_NEEDS_TO_BE_INITIALIZED", comment: ""))
                    break
                case SWDKErrorCode.UNKNOWN_SWDK_UUID://17
                    self.showErrorDialog(message: NSLocalizedString("UNKNOWN_SDK_UUID", comment: ""))
                    break
                case SWDKErrorCode.TIMEOUT://39
                    self.showErrorDialog(message: NSLocalizedString("ERROR_TIMEOUT", comment: ""))
                    break
                case SWDKErrorCode.WRONG_OTP://43
                    self.showErrorDialog(message: NSLocalizedString("ERROR_WRONG_OTP", comment: ""))
                    break
                case SWDKErrorCode.CONFIG_SERVER_API_ERROR://44
                    self.showErrorDialog(message: NSLocalizedString("CONFIG_SERVER_API_ERROR", comment: ""))
                    break
                    
                case SWDKErrorCode.CANNOT_RETREIVE_API_VERSION://46
                    self.showErrorDialog(message: NSLocalizedString("ERROR_CANNOT_RETREIVE_API_VERSION", comment: ""))
                    break
                case SWDKErrorCode.ACTIVATION_CODE_IS_INVALID://47
                    self.showErrorDialog(message: NSLocalizedString("ERROR_ACTIVATION_CODE_IS_INVALID", comment: ""))
                    break
                case SWDKErrorCode.PASSCODE_NUMERIC_CHARACTER_INVALID://49
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSCODE_NUMERIC_CHARACTER_INVALID", comment: ""))
                    break
                case SWDKErrorCode.PASSCODE_MIXED_CASE_INVALID://50
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSCODE_MIXED_CASE_INVALID", comment: ""))
                    break
                case SWDKErrorCode.PASSCODE_SPECIAL_SYMBOL_INVALID://51
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSCODE_SPECIAL_SYMBOL_INVALID", comment: ""))
                    break
                case SWDKErrorCode.PASSCODE_LENGTH_INVALID://52
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSCODE_LENGTH_INVALID", comment: ""))
                    break
                case SWDKErrorCode.PASSCODE_GENERAL_ERROR://53
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSCODE_GENERAL_ERROR", comment: ""))
                    break
                case SWDKErrorCode.PASSCODE_EMPTY://54
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSCODE_EMPTY", comment: ""))
                    break
                case SWDKErrorCode.PASSWORD_REPEAT_ERROR://55
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSWORD_REPEAT", comment: ""))
                    break
                case SWDKErrorCode.PASSWORD_WRONG://56
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSWORD_WRONG", comment: ""))
                    break
                case SWDKErrorCode.PASSCODE_CONTAINS_USERNAME://57
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSCODE_CONTAINS_USERNAME", comment: ""))
                    break
                case SWDKErrorCode.PASSCODE_CONTAINS_KEYWORD://58
                    self.showErrorDialog(message: NSLocalizedString("ERROR_PASSCODE_CONTAINS_KEYWORD", comment: ""))
                    break
                case SWDKErrorCode.NETWORK_NOT_AVAILABLE://59
                    self.showErrorDialog(message: NSLocalizedString("NETWORK_NOT_AVAILABLE", comment: ""))
                    break
                case SWDKErrorCode.MAX_DEVICES_REACHED://60
                    self.showErrorDialog(message: NSLocalizedString("MESSAGE_SELECT_ORG_HAS_LIMIT_DEVICE", comment: ""))
                    break
                case SWDKErrorCode.CAPTCHA_EXPIRED://62
                    self.showErrorDialog(message: NSLocalizedString("CAPTCHA_EXPIRED", comment: ""))
                    break
                case SWDKErrorCode.CAPTCHA_INVALID://63
                    self.showErrorDialog(message: NSLocalizedString("CAPTCHA_INVALID", comment: ""))
                    break
                case .LOGIN_BLOCKED://64
                    self.showErrorDialog(message: NSLocalizedString("LOGIN_BLOCKED", comment: ""))
                    break
                case .NEED_BLUETOOTH://68
                    self.showErrorDialog(message: NSLocalizedString("ERROR_NEED_BLUETOOTH", comment: ""))
                    break
                case .NO_SENSOR_FOUND://69
                    self.showErrorDialog(message: NSLocalizedString("NO_SENSOR_FOUND", comment: ""))
                    break
                case .APP_VERSION_MIGRATE_FAILED: //104
                    self.showErrorDialog(message: NSLocalizedString("MIGRATE_FAILED", comment: ""))
                    break;
                case .APP_VERSION_INVALID, .INVALID_TOKEN, .LOGIN_USER_NOT_FOUND, .ERROR_PASSWORD_HAS_EXPIRED, .USER_HAS_ARCHIVED, .COMPANY_IS_DENIED, .DEVICE_IS_LOGOUT, .LOGIN_USER_HAS_ARCHIVED, .ACCOUNT_NOT_FOUND:
                    let _ = DialogUtils.showDialogSingleButton(controller: self,
                                                               title: NSLocalizedString("TITLE_ERROR_DIALOG", comment: ""),
                                                               message: NSLocalizedString("TOKEN_LOGOUT", comment: "")) { () in
                        self.showProgressDialog()
                    }
                default:
                    let errotTitle = "" + NSLocalizedString("TITLE_ERROR_DIALOG", comment: "") + " (\(String(error.code)))"
                    let errorMessage = "" + NSLocalizedString("ERROR_UNHANDLE", comment: "") + " (\(String(error.code)))"
                    self.showErrorDialog(title: errotTitle, message: errorMessage)
            }
        }
    }
}
