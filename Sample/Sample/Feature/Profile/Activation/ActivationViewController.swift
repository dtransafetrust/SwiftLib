//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit
import GoogleSignIn

class ActivationViewController: BaseAuthenticationController, GIDSignInDelegate {
    
    @IBOutlet weak var phoneOrEmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var pin: UITextField!
    @IBOutlet weak var identifyLable: UILabel!
    @IBOutlet weak var pinLable: UILabel!
    
    private let authenticationService = SWDK.sharedInstance().authenticationService();
    private let sessionManager = SWDK.sharedInstance().sessionManager();
    var userIdentify: String? = nil
    var isValidEmail: Bool = true
    var activationCode: String? = nil
    var isInputPass: Bool = false
    
    @IBAction func onActivate() {
        dismissKeyboard()
        do {
            var phoneOrEmailVal = phoneOrEmail.text!
            var pass = ""
            var confirmPass = ""
            activationCode = try pin.validatedText(validationType: ValidatorType.pincode)
            
            if (!isInputPass) {
                //check activation info
                if (isValidEmail) {
                    //active account
                    showProgressDialog()
                    loginModel.activateAccounChecking(email: phoneOrEmailVal, otpCode: activationCode!) {(authenInfo, error) in
                        self.hideProgressDialog()
                        if (error != nil) {
                            print(error!.message)
                            self.showErrorDialog(message: error!.message)
                            return;
                        }
                        //ok. go to activate account
                        if (authenInfo != nil) {
                            if (authenInfo!.authenticationType == AuthenticationType.googleOauth) {
                                //active use google
                                self.showProgressDialog()
                                GIDSignIn.sharedInstance().delegate = self
                                GIDSignIn.sharedInstance()?.presentingViewController = self
                                GIDSignIn.sharedInstance()?.signIn()
                                return
                            } else if (authenInfo!.authenticationType == AuthenticationType.saml) {
                                //active use saml
                                self.loginModel.loginSaml(email: phoneOrEmailVal, activationCode: self.activationCode!) { (info2, error2) in
                                    if (info2 != nil  && Int(info2!)! > 0) {
                                        self.loadOrganizationList(accountId: info2!)
                                    }
                                }
                                return
                            } else if (authenInfo!.authenticationType == AuthenticationType.oAuth) {
                                //active use the saved oAuth token
                                let savedToken = self.loginModel.getCacheOAuthToken(email: phoneOrEmailVal)
                                if (savedToken != nil) {
                                    self.activateAccount(email: phoneOrEmailVal, password: savedToken!, pin: self.activationCode!)
                                } else {
                                    self.loginModel.getOAuthToken(email: phoneOrEmailVal) { token, error2 in
                                        if (error2 != nil) {
                                            print(error2!.message)
                                            self.showErrorDialog(message: error2!.message)
                                            return
                                        }
                                        if (token != nil) {
                                            self.activateAccount(email: phoneOrEmailVal, password: token!, pin: self.activationCode!)
                                        }
                                    }
                                }
                                return
                            } else {
                                //normal active
                                self.isInputPass = true
                                self.updateUI()
                                return
                            }
                        }
                    }
                    
                } else {
                    showProgressDialog();
                    loginModel.activateAccountUsingOtp(phone: phoneOrEmailVal ,otpCode: activationCode!) { (account, error) in
                        if (error != nil) {
                            self.hideProgressDialog()
                            return;
                        }
                        self.hideProgressDialog()
                        self.loadOrganizationList(accountId: "\(account!)")
                    }
                }
                return;
            }
            if (isValidEmail) {
                phoneOrEmailVal = try phoneOrEmail.validatedText(validationType: ValidatorType.email)
                pass = try password.validatedText(validationType: ValidatorType.password)
                confirmPass = try confirmPassword.validatedText(validationType: ValidatorType.confirmpassword)
                if(!pass.elementsEqual(confirmPass)) {
                    showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_PASSWORD_CONFIRM_PASSWORD)
                    return
                }
            } else {
                phoneOrEmailVal = try phoneOrEmail.validatedText(validationType: ValidatorType.phonenumber)
            }
            
            // activate account
            activateAccount(email: phoneOrEmailVal, password: pass, pin: activationCode!)
            
        } catch (let error) {
            showErrorDialog(message: (error as! ValidationError).message)
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            hideProgressDialog()
            print("\(error.localizedDescription)")
            showToastMessage(message: error.localizedDescription)
        } else {
            let userName = (phoneOrEmail?.text)!.replacingOccurrences(of: " ", with: "")
            if (!user.profile.email.lowercased().starts(with: userName.lowercased())){
                hideProgressDialog()
                self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_USER_IDENTIFIER)
                return;
            }
            activateAccount(email: user.profile.email, password: user.authentication.idToken, pin: activationCode!)
        }
    }
    
    func updateUI() -> Void {
        password.isHidden = !isInputPass
        passwordLabel.isHidden = !isInputPass
        confirmPassword.isHidden = !isInputPass
        confirmPasswordLabel.isHidden = !isInputPass
        isValidEmail = phoneOrEmail.text!.isValidEmail()
        if (!isValidEmail) {
            password.isEnabled = false
            confirmPassword.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isInputPass = false
        password.isSecureTextEntry = true
        confirmPassword.isSecureTextEntry = true
        phoneOrEmail.text = userIdentify
        pin.text = activationCode
        updateUI()
    }
    
    func activationFromLink(activationUrl: String, password: String) {
        showProgressDialog()
        authenticationService.activateAccount(urlData: activationUrl, password: password) { (accountId, error) in
            self.hideProgressDialog()
            self.handleActivationResult(accountId: accountId, error: error)
        }
    }
}
