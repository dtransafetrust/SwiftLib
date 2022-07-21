// // TrustIssuer_Use
// Copyright (c) Safetrust, Inc. - All Rights Reserved // TrustIssuer_Use
// Unauthorized copying of this file, via any medium is strictly prohibited // TrustIssuer_Use
// Proprietary and confidential // TrustIssuer_Use
// // TrustIssuer_Use
// TrustIssuer_Use
import SafetrustWalletDevelopmentKit // TrustIssuer_Use
import GoogleSignIn // TrustIssuerNotUse
import PhoneNumberKit // TrustIssuerNotUse
import UIKit // TrustIssuer_Use
// TrustIssuer_Use
// TrustIssuer_Useclass LoginViewController: BaseAuthenticationController,  UITextFieldDelegate {
class LoginViewController: BaseAuthenticationController, GIDSignInDelegate,  UITextFieldDelegate {

    private var loginType = AuthenticationType.emailOrMobileNumber
    private let selectIssuerOption = [SWDKConstant.TRUSTED_ISSUER, SWDKConstant.ONLINE]
    private var appDidBecomeActive: Bool = false
    @IBOutlet weak var userNameInput: UITextField! // TrustIssuer_Use
    @IBOutlet weak var passwordInput: UITextField! // TrustIssuer_Use
    @IBOutlet weak var userNameErrorMessage: UILabel! // TrustIssuer_Use
    @IBOutlet weak var loginButton: UIButton! // TrustIssuer_Use
    @IBOutlet weak var sdkVersionCode: UILabel! // TrustIssuer_Use
    @IBOutlet weak var resendOtpButton: UIButton! // TrustIssuer_Use
    @IBOutlet weak var callMeButton: UIButton! // TrustIssuer_Use
    
    private var normalLogin: Bool = false
    // TrustIssuer_Use
    @IBAction func usernameInputTextChanged(_ sender: UITextField) { // TrustIssuer_Use
        // update ui everytime user finish input username
        normalLogin = false
        updateUI()
        if (sender.text!.hasPrefix("+")) {
            sender.text = PartialFormatter().formatPartial(sender.text!)
        }
    } // TrustIssuer_Use
    // TrustIssuer_Use
    @IBAction func onUserNameInputEnd(_ sender: UITextField) { // TrustIssuer_Use
        let username = sender.text!
        if (username.isValidPhoneNumber() && username.prefix(1) != "+") {
            showCountryCodeFixingDialog(phoneNumber: username) { (phoneNumber) in
                self.userNameInput.text = PartialFormatter().formatPartial(phoneNumber)
            }
        }
    } // TrustIssuer_Use

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == userNameInput) {
            onUserNameInputEnd(textField)
            return true
        }
        return false
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            hideProgressDialog()
            print("\(error.localizedDescription)")
            showToastMessage(message: error.localizedDescription)
        } else {
            let userName = (userNameInput?.text)!.replacingOccurrences(of: " ", with: "")
            if (!user.profile.email.lowercased().starts(with: userName.lowercased())) {
                hideProgressDialog()
                self.showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_USER_IDENTIFIER)
                return;
            }
            loginType = .googleOauth
            self.userNameInput.text = user.profile.email
            self.passwordInput.text = user.authentication.idToken
            updateUI()
            self.loginWithGoogleOauthToken(email: user.profile.email, idToken: user.authentication.idToken)
        }
    }
    // TrustIssuer_Use
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // TrustIssuer_Use
        super.prepare(for: segue, sender: sender) // TrustIssuer_Use
        if (segue.destination is CredentialListViewController) { // TrustIssuer_Use
            (segue.destination as! CredentialListViewController).data = loginModel.credentialList // TrustIssuer_Use
        } // TrustIssuer_Use
        else if (segue.destination is RegisterDeviceViewController) {
            (segue.destination as! RegisterDeviceViewController)
                .setup(email: userNameInput.text!,
                    password: (passwordInput.text)!,
                    accountId: loginModel.accountId!,
                    loginType: loginType,
                    registerResultCallback: { (accountId, error) in
                        print("\n======  registerResultCallback ====== \(accountId ?? "")")
                        self.appDidBecomeActive = false
                        if (error != nil) {
                            self.showErrorDialog(message: error!.message)
                        }else if (accountId != nil) {
                            self.loginModel.accountId = accountId
                            self.loadOrganizationList(accountId: accountId!)
                        }
                    })
        } else if (segue.destination is ActivationViewController) {
            (segue.destination as! ActivationViewController).userIdentify = userNameInput.text
            (segue.destination as! ActivationViewController).activationCode = passwordInput.text
        } else if (segue.destination is RegisterViewController) {
            (segue.destination as! RegisterViewController).userIdentify = userNameInput.text
        } else if (segue.destination is CaptchaViewController) {
            let phoneNumber = (self.userNameInput.text)!.replacingOccurrences(of: " ", with: "")
            
            let captchaVC = segue.destination as! CaptchaViewController
            captchaVC.phoneNumber = phoneNumber
            captchaVC.callback = { captchaCode in
                self.updateUI()
                self.passwordInput.becomeFirstResponder()
            }
        }
    } // TrustIssuer_Use

    fileprivate func initOnlineSession() {
        //Todo check current mode (online)
        initAndRestoreSession()
        updateUI()
        //Prepare for login with google
        GIDSignIn.sharedInstance()?.clientID = SWDKConstant.clientID
        userNameInput.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resendOtpButton.setTitle(SWDKConstant.RESEND_BY_SMS, for: .normal)
        callMeButton.setTitle(SWDKConstant.CALL_ME, for: .normal)
    }
    // TrustIssuer_Use
    override func viewDidAppear(_ animated: Bool) { // TrustIssuer_Use
        super.viewDidAppear(animated) // TrustIssuer_Use
        if(!appDidBecomeActive) {
            initOnlineSession()
// TrustIssuer_Use            initTrustedIssuerSession()
        }
    } // TrustIssuer_Use

    fileprivate func initialize() {
        initOnlineSession()
    }
// TrustIssuer_Use
// TrustIssuer_Use    fileprivate func initTrustedIssuerSession() {
// TrustIssuer_Use        print("=================initTrustedIssuerSession================")
// TrustIssuer_Use        showProgressDialog()
// TrustIssuer_Use        loginModel.initTrustedIssuerModel(callback: { (error) in
// TrustIssuer_Use            print("=================initTrustedIssuerSession================ returned callback")
// TrustIssuer_Use            self.hideProgressDialog()
// TrustIssuer_Use            if(error == nil){
// TrustIssuer_Use                let sessionManager = SWDK.sharedInstance().sessionManager()
// TrustIssuer_Use               self.showProgressDialog()
// TrustIssuer_Use               sessionManager.startSession() { (error) in
// TrustIssuer_Use                    //check import or get
// TrustIssuer_Use                    self.hideProgressDialog()
// TrustIssuer_Use                    self.validateAndImportData()
// TrustIssuer_Use                }
// TrustIssuer_Use            } // if
// TrustIssuer_Use        })
// TrustIssuer_Use    }

    private func initAndRestoreSession() {
        showProgressDialog()
        loginModel.initModel { (error) in
            if(error != nil){
                self.hideProgressDialog()
                self.showErrorDialog(error: error)
                return
            }
            // display the current sdk version
            self.hideProgressDialog()
            self.updateSDKInfo()
            let sessionManager = SWDK.sharedInstance().sessionManager()

            //Check if user is logged in and the persisted session is valid
            if (try! sessionManager.isSessionValid()) {
                // restore it
                sessionManager.startSession() { (error) in
                    // load and display the credentials
                    self.hideProgressDialog()
                    if(self.getActivationUrl().isEmpty) {
                        self.loadCredentials()
                    }
                }
            } else {
                GIDSignIn.sharedInstance()?.signOut()
            }
        }
    }

    private func updateUI() {
        let username = userNameInput.text!
        resendOtpButton.isHidden = true
        callMeButton.isHidden = true
        // Login with email address or default case
        if (username.isEmpty) {
            passwordInput.isHidden = true
            loginButton.setTitle("Next", for: UIControl.State.normal)
            userNameErrorMessage.isHidden = true
            loginModel.cancelOtpVerifyProcess()
        } else if (username.isValidEmail()) {
            if (normalLogin) {
                passwordInput.placeholder = "Enter Password"
                passwordInput.isSecureTextEntry = true
                loginButton.setTitle("Login", for: UIControl.State.normal)
                passwordInput.isHidden = false
            } else {
                passwordInput.isHidden = true
                loginButton.setTitle("Next", for: UIControl.State.normal)
            }
            passwordInput.keyboardType = UIKeyboardType.default
            userNameErrorMessage.isHidden = true
        } else if (username.isValidPhoneNumber()) {
            passwordInput.placeholder = "Enter OTP"
            passwordInput.isSecureTextEntry = false
            passwordInput.keyboardType = UIKeyboardType.numberPad
            userNameErrorMessage.isHidden = true
            if (loginModel.isOtpWaiting()) {
                passwordInput.isHidden = false
                loginButton.setTitle("Login", for: UIControl.State.normal)
                resendOtpButton.isHidden = false
                callMeButton.isHidden = false
            } else {
                passwordInput.isHidden = true
                loginButton.setTitle("Request Otp", for: UIControl.State.normal)
            }
        } else {
            // show invalid username format
            loginModel.cancelOtpVerifyProcess()
            passwordInput.isHidden = true
            loginButton.setTitle("Next", for: UIControl.State.normal)
        }
    }

    private func isLoginByEmail() -> Bool {
        return userNameInput.text!.isValidEmail()
    }

    private func validateInput() -> Bool {
        return true
    }

    private func updateSDKInfo() {
        self.sdkVersionCode.text = loginModel.getSDKInfo().version
    }

    private func login(email: String) {
        let password : String = ""
        showProgressDialog()
        print("\n========= start login ====\n")
        loginModel.getAuthenticationInfo(email: email) { (info, error) in
            if (error != nil) {
                print("=== onError ==== \(error!.code)")
                self.hideProgressDialog()
                self.handleLoginError(email: email, password: password, error: error)
                return;
            }
            if (info != nil) {
                self.hideProgressDialog()
                if (info!.authenticationType == AuthenticationType.googleOauth) {
                    //login by google
                    self.appDidBecomeActive = true
                    self.showProgressDialog()
                    GIDSignIn.sharedInstance().delegate = self
                    GIDSignIn.sharedInstance()?.presentingViewController = self
                    GIDSignIn.sharedInstance()?.signIn()
                    
                } else if (info!.authenticationType == AuthenticationType.saml) {
                    //login by saml
                    self.loginModel.loginSaml(email: email, activationCode: "") { (info2, error2) in
                        if (info2 != nil && Int(info2!)! > 0){
                            self.loadOrganizationList(accountId: info2!)
                        }
                    }
                } else if (info!.authenticationType == AuthenticationType.oAuth) {
                    // login by generic OAuth
                    self.loginModel.getOAuthToken(email: email) { (token, error2) in
                        
                        if (error2 != nil) {
                            print("=== onError ==== \(error2!.code)")
                            self.handleLoginError(email: email, password: token ?? "", error: error)
                            self.hideProgressDialog()
                            return
                        }
                        self.performLoginWithOAuthToken(email: email, token: token!)
                    }
                    
                } else {
                    //normal login
                    self.normalLogin = true;
                    self.updateUI()
                }
                return;
            }
        }
    }


    private func performLogin(email: String, password: String) {
        showProgressDialog()
        print("\n========= start login ====\n")
        loginModel.login(email: email, password: password) { (account, error) in
            self.hideProgressDialog()
            if (error != nil) {
                print("=== onError ==== \(error!.code)")
                self.handleLoginError(email: email, password: password, error: error)
                return;
            }
            print("=== onSuccess ==== \(account!.id)")
            self.loadOrganizationList(accountId: "\(account!.id)")
        }
    }

    private func loginWithGoogleOauthToken(email: String, idToken: String) {
        loginModel.loginWithGoogleOauthToken(email: email, idToken: idToken) { (account, error) in
           self.hideProgressDialog()
            if (error != nil) {
                self.handleLoginError(email: email, password: idToken, error: error)
                return
            }
            self.loadOrganizationList(accountId: "\(account!.id)");
        }
    }

    private func handleLoginError(email: String, password: String, error: ErrorDetail?) {
        switch SWDKErrorCode.init(rawValue: Int32(error!.code)!)! {
        case SWDKErrorCode.ACCOUNT_NOT_FOUND:
            showAccountNotFoundErrorDialog()
            break;
        case SWDKErrorCode.DEVICE_NOT_FOUND:
            startRegisterDeviceProcess(accountId: error!.accountId)
            break;
        default:
            showErrorDialog(message: error!.message)
        }
    }

    private func startRegisterDeviceProcess(accountId: String) {
        loginModel.accountId = accountId
        performSegue(withIdentifier: "start_register_device", sender: nil)
    }
    // TrustIssuer_Use
    //======== user logged ======================  // TrustIssuer_Use
    private func loadCredentials() { // TrustIssuer_Use
        checkAndVerifyPasscode { // TrustIssuer_Use
            self.showProgressDialog() // TrustIssuer_Use
            self.loginModel.loadCredentials() { (creds, error) in // TrustIssuer_Use
                self.hideProgressDialog() // TrustIssuer_Use
                if (error != nil) { // TrustIssuer_Use
                    self.showErrorDialog(message: error!.message) // TrustIssuer_Use
                    return // TrustIssuer_Use
                } // TrustIssuer_Use
                self.performSegue(withIdentifier: "session_logged", sender: nil) // TrustIssuer_Use
            } // TrustIssuer_Use
        } // TrustIssuer_Use
        // TrustIssuer_Use
        SWDK.sharedInstance().configurationService().registerPasscodeEvent() { (credentialID: String) in // TrustIssuer_Use
            print("show pass code with cre ID : " + credentialID) // TrustIssuer_Use
           self.showInputDialog(){ (passcode) in // TrustIssuer_Use
            SWDK.sharedInstance().configurationService().verifyPasscode(passcode: passcode, // TrustIssuer_Use
               completion: { (isVerified, error) in // TrustIssuer_Use
                if(error != nil) { // TrustIssuer_Use
                    // show verify input again // TrustIssuer_Use
                    self.showErrorDialog(message: error!.message) // TrustIssuer_Use
                    return // TrustIssuer_Use
                } // TrustIssuer_Use
            }) // TrustIssuer_Use
           } // TrustIssuer_Use
        } // TrustIssuer_Use
    } // TrustIssuer_Use

    private func getActivationUrl() -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.activationUrl
    }
// TrustIssuer_Use
// TrustIssuer_Use    private func validateAndImportData() {
// TrustIssuer_Use        showProgressDialog()
// TrustIssuer_Use        let trustedIssuerArray = [
// TrustIssuer_Use            SWDKConstant.credential1
// TrustIssuer_Use          //  SWDKConstant.credential2,
// TrustIssuer_Use          //  SWDKConstant.credential3
// TrustIssuer_Use        ]
// TrustIssuer_Use        var importFinishedCount = 0
// TrustIssuer_Use        for index in (0...trustedIssuerArray.count - 1) {
// TrustIssuer_Use            self.loginModel.validateAndImportData(data: trustedIssuerArray[index]) { (credentials, error) in
// TrustIssuer_Use
// TrustIssuer_Use               importFinishedCount += 1
// TrustIssuer_Use
// TrustIssuer_Use               if (importFinishedCount == trustedIssuerArray.count) {
// TrustIssuer_Use                    self.hideProgressDialog()
// TrustIssuer_Use                    self.loadCredentials()
// TrustIssuer_Use                }
// TrustIssuer_Use            }
// TrustIssuer_Use        }
// TrustIssuer_Use    }
    // TrustIssuer_Use
    // MARK: - Action methods // TrustIssuer_Use
    // TrustIssuer_Use
    @IBAction func doLoginWithGoogle() { // TrustIssuer_Use
        appDidBecomeActive = true
        showProgressDialog()
        GIDSignIn.sharedInstance()?.signIn()
    } // TrustIssuer_Use
    // TrustIssuer_Use
    @IBAction func doLogin() { // TrustIssuer_Use
        dismissKeyboard()
        let userName = (userNameInput?.text)!.replacingOccurrences(of: " ", with: "")
        if (isLoginByEmail()) {
            if(normalLogin){
                performLogin(email: userName, password: (passwordInput?.text)!)
                return;
            }
            showProgressDialog();
            loginModel.getAccountStatus(userIdentifier: userName) { (status, error) in
                self.hideProgressDialog()
                
                if (error != nil) {
                    return;
                }
                if (status == SWDKAccountStatus.accountPendingActivation) {
                    // active account
                    //move to activation page
                    self.performSegue(withIdentifier: "active_account", sender: nil)
                    
                } else if (status == SWDKAccountStatus.accountNotFound) {
                    // sign up
                    self.performSegue(withIdentifier: "register_account", sender: nil)
                    
                } else if (status == SWDKAccountStatus.accountExisted || status == SWDKAccountStatus.deviceNotFound) {
                    // login
                    self.login(email: userName)
                }
            }
        } else if (loginModel.isOtpWaiting()) {
            showProgressDialog()
            loginModel.verifyOtp(otpCode: passwordInput.text!) { (account, error) in
                
                if (error != nil) {
                    self.hideProgressDialog()
                    return;
                }
                self.hideProgressDialog()
                self.loadOrganizationList(accountId: "\(account!.id)")
            }
            
        } else if(userName.isValidPhoneNumber()) {
            if (userName.prefix(1) != "+") {
                showCountryCodeFixingDialog(phoneNumber: userName) { (phoneNumber) in
                    self.userNameInput.text = phoneNumber
                }
                return
            }
            showProgressDialog()
            let emailPhone = userName.normalizationPhoneNumber()
            loginModel.getAccountStatus(userIdentifier: emailPhone) { (status, error) in
                if (error != nil) {
                    self.hideProgressDialog()
                    return;
                }
                if (status! == SWDKAccountStatus.accountPendingActivation) {
                    //move to activation page to acctive account by phone
                    self.performSegue(withIdentifier: "active_account", sender: nil)
                    self.hideProgressDialog()
                    return;
                } else if (status! == SWDKAccountStatus.accountNotFound){
                    // register new
                    self.performSegue(withIdentifier: "register_account", sender: nil)
                    return
                }else {
                    self.loginModel.loginWithPhone(phoneNumber: emailPhone) { (captcha, loginError) in
                        self.hideProgressDialog()
                        
                        if (captcha != nil) { // CAPTCHA_REQUIRE
                            self.performSegue(withIdentifier: "login_to_captcha_dialog", sender: self)
                        } else if loginError != nil {
                            self.showErrorDialog(message: loginError!.code + " - " + loginError!.message)
                        } else {
                            self.updateUI()
                            self.passwordInput.becomeFirstResponder()
                        }
                    }
                }
            }
        } else {
            showErrorDialog(message: SWDKConstant.MESSAGE_VALIDATE_USER_IDENTIFIER)
        }
    } // TrustIssuer_Use
    // TrustIssuer_Use
    @IBAction func tappedResendOTP(_ sender: Any) { // TrustIssuer_Use
        let phoneNumber = (self.userNameInput.text)!.replacingOccurrences(of: " ", with: "")
        
        self.showProgressDialog()
        self.loginModel.loginWithPhone(phoneNumber: phoneNumber) { (captcha, loginError) in
            self.hideProgressDialog()
            
            if (captcha != nil) { // CAPTCHA_REQUIRE
                self.performSegue(withIdentifier: "login_to_captcha_dialog", sender: self)
            } else if loginError != nil {
                self.showErrorDialog(message: loginError!.code + " - " + loginError!.message)
            } else {
                self.updateUI()
                self.passwordInput.becomeFirstResponder()
            }
        }
    } // TrustIssuer_Use
    // TrustIssuer_Use
    @IBAction func tappedCallMe(_ sender: Any) { // TrustIssuer_Use
        let userName = (self.userNameInput.text)!.replacingOccurrences(of: " ", with: "")
        let emailPhone = userName.normalizationPhoneNumber()
        
        self.showProgressDialog()
        self.loginModel.requestCallForOtp(phoneNumber: emailPhone) { (captcha, callResult ,loginError) in
            self.hideProgressDialog()
            
            if (loginError != nil || captcha != nil) {
                self.showLoginErrorDialog(error: loginError, captcha: captcha)
                return
                
            } else if (callResult != nil && callResult!.timeBlock > 0){
                self.updateUI()
                self.passwordInput.becomeFirstResponder()
            }
        }
    } // TrustIssuer_Use
    
    // MARK: - Request Otp methods
    
    private func showLoginErrorDialog(error: ErrorDetail!, captcha: Captcha?) {
        if (captcha != nil) { // CAPTCHA_REQUIRE
            self.performSegue(withIdentifier: "login_to_captcha_dialog", sender: self)
        } else {
            self.showErrorDialog(message: error!.code + " - " + error!.message)
        }
    }
    
    // MARK: - Private methods
    
    private func performLoginWithOAuthToken(email: String, token: String) {
        loginModel.loginWithOAuthToken(email: email, token: token) { (account, error) in
            self.hideProgressDialog()
            if (error != nil) {
                print("=== onError ==== \(error!.code)")
                self.handleLoginError(email: email, password: token, error: error)
                return;
            }
            print("=== onSuccess ==== \(account!.id)")
            self.loadOrganizationList(accountId: "\(account!.id)")
        }
    }
} // TrustIssuer_Use
