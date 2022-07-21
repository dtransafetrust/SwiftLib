//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit
import GoogleSignIn

class LinkActivationViewController: BaseAuthenticationController, GIDSignInDelegate{

    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var username: UITextField!

    private let authenticationService = SWDK.sharedInstance().authenticationService();
    private let sessionManager = SWDK.sharedInstance().sessionManager();

    var activationCode: String? = nil
    
    @IBAction func onActivate() {
        dismissKeyboard()
        let activationUrl = getActivationUrl()
        if(validateInput()) {
            self.activationFromLink(activationUrl: activationUrl, password: password.text!)
        }
        
    }
    
    private func processPendingData(){
        let email = ActivationUtils.extractEmailFromLink(activateUrl: getActivationUrl())
               let isActiveAccount = ActivationUtils.extractIsActiveAccountFromLink(activateUrl: getActivationUrl()) ?? false
               activationCode = ActivationUtils.extractPinFromLink(activateUrl: getActivationUrl());
               if(email != nil && !isActiveAccount) {
                   self.activateDeviceFromlink(activateUrl: getActivationUrl())
               } else if(email != nil && activationCode != nil) {
                   username.text = email
                   passwordLabel.isHidden = true
                   password.isHidden = true
                   confirmPasswordLabel.isHidden = true
                   confirmPassword.isHidden = true
                   showProgressDialog()
                   loginModel.activateAccounChecking(email: email!, otpCode: activationCode!) {(authenInfo, error) in
                       self.hideProgressDialog()
                       if (error != nil) {
                           self.showErrorDialog(message: error!.message)
                       } else if (authenInfo!.authenticationType == AuthenticationType.googleOauth) {
                           //active use google
                            self.showProgressDialog()
                            //wait a sec for this view is loaded and ready for attach the google sign-in
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                GIDSignIn.sharedInstance().delegate = self
                                GIDSignIn.sharedInstance()?.presentingViewController = self
                                GIDSignIn.sharedInstance()?.signIn()
                            }
                           
                       } else if (authenInfo!.authenticationType == AuthenticationType.saml) {
                           //active use saml
                           self.loginModel.loginSaml(email: email!, activationCode:self.activationCode!){ (info2, error2) in
                               if (info2 != nil  && Int(info2!)! > 0){
                                   self.handleActivationResult(accountId: info2, error: error)
                               }
                           }
                       } else {
                           //setup UI for Normal active
                           self.passwordLabel.isHidden = false
                           self.password.isHidden = false
                           self.confirmPasswordLabel.isHidden = false
                           self.confirmPassword.isHidden = false
                       }
                   }
               } else {
                   self.showToastMessage(message: SWDKConstant.ACTIVATION_LINK_INVALID)
                   navigateToActivationInputForm()
               }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData();
    }
    
    private func initData(){
        if (loginModel.isInitilized()){
            self.processPendingData()
        } else {
            showProgressDialog()
            GIDSignIn.sharedInstance()?.clientID = SWDKConstant.clientID
            loginModel.initModel { (error) in
                self.hideProgressDialog()
                self.processPendingData()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
           if let error = error {
               hideProgressDialog()
               print("\(error.localizedDescription)")
               showToastMessage(message: error.localizedDescription)
           } else {
                let usrname = (username?.text)!.replacingOccurrences(of: " ", with: "")
            if (!user.profile.email.lowercased().starts(with: usrname.lowercased())){
                    hideProgressDialog()
                    self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_USER_IDENTIFIER)
                    return;
                }
               activateAccount(email: user.profile.email, password: user.authentication.idToken, pin: activationCode!)
           }
       }
    
    func navigateToActivationInputForm() {
        dismiss(animated: false) {
            self.performSegue(withIdentifier: "active_account_input_form", sender: nil)
        }
    }

    private func validateInput() -> Bool {
        if(password.text?.isEmpty ?? false || confirmPassword.text?.isEmpty ?? false) {
            showErrorDialog(message: SWDKConstant.MESSAGE_FILL_INFORMATION)
            return false
        } else if(password.text != confirmPassword.text) {
            showErrorDialog(message: SWDKConstant.MESSAGE_PASSWORD_NOT_MATCH)
            return false
        }
        return true
    }

    func activationFromLink(activationUrl: String, password: String) {
        showProgressDialog()
        authenticationService.activateAccount(urlData: activationUrl, password: password) { (accountId, error) in
            self.hideProgressDialog()
            self.handleActivationResult(accountId: accountId, error: error)
        }
    }

    func activateDeviceFromlink(activateUrl: String) {
        showProgressDialog()
        authenticationService.activateDeviceFromLink(urlData: activateUrl) { (accountId, error) in
            self.hideProgressDialog()
            self.handleActivationResult(accountId: accountId, error: error)
        }
    }

    func getActivationUrl() -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.activationUrl
    }
}
