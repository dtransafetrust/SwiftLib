// // TrustIssuer_Use
// Copyright (c) Safetrust, Inc. - All Rights Reserved // TrustIssuer_Use
// Unauthorized copying of this file, via any medium is strictly prohibited // TrustIssuer_Use
// Proprietary and confidential // TrustIssuer_Use
// // TrustIssuer_Use
// TrustIssuer_Use
import UIKit // TrustIssuer_Use
import SafetrustWalletDevelopmentKit // TrustIssuer_Use
// TrustIssuer_Use
class LoginModel { // TrustIssuer_Use
    private let sessionManager = SWDK.sharedInstance().sessionManager();
    private let credentialService = SWDK.sharedInstance().credentialService()
    private let authenticationService = SWDK.sharedInstance().authenticationService()
    private let configurationService = SWDK.sharedInstance().configurationService()
// TrustIssuer_Use    private let trustedIssuerService = SWDK.sharedInstance().trustedIssuerService()

    private var otpRequestedPhoneNumber: String? = nil
    var credentialList: Array<Credential>? = nil // TrustIssuer_Use
    var organizations: Array<Organization>? = nil
    var accountId: String? = nil
    var samlURL: String? = nil
    
    private static var oAuthTokenMap: Dictionary = [String : String]()
    private static var IsServerInit: Bool = false
    
    func initModel(callback: @escaping (ErrorDetail?) -> Void) {
        SWDK.sharedInstance().initialize(credentialManagerServiceUrl: SWDKConstant.serverUrl,
            applicationUUID: SWDKConstant.appUUID,
            sdkUUID: SWDKConstant.sdkUUID ){ (error) in
                if (error != nil){
                    LoginModel.IsServerInit = true
                }
                callback(error)
            }
    }

    func isInitilized() -> Bool{
        return LoginModel.IsServerInit
    }
    
    func processCallbackResult(account: Account?,
        error: ErrorDetail?,
        completion: @escaping (_ account: Account?, _ error: ErrorDetail?) -> Void) {
        if (account != nil) {
            self.accountId = account!.id
        }
        completion(account, error)
    }

    func login(email: String,
        password: String,
        completion: @escaping (_ account: Account?, _ error: ErrorDetail?) -> Void) {
        
//        configurationService.getBeaconState() { (result, error) in
//            print("Result ====: " + result.debugDescription);
//
//        }
        authenticationService.authenticateWithEmail(email: email, password: password, completion: { (accountInfo, errorInfo) in
            self.processCallbackResult(account: accountInfo, error: errorInfo, completion: completion)
        })
    }
    
    func loginWithOAuthToken(email: String,
        token: String,
        completion: @escaping (_ account: Account?, _ error: ErrorDetail?) -> Void) {
        authenticationService.authenticateWithOAuthToken (email: email, token: token, completion: { (accountInfo, errorInfo) in
            self.processCallbackResult(account: accountInfo, error: errorInfo, completion: completion)
        })
    }

    func loginWithPhone(phoneNumber: String,
                        completion: @escaping (Captcha?, ErrorDetail?) -> Void) {
        
        self.otpRequestedPhoneNumber = phoneNumber
        
        authenticationService.requestOtpCodeForPhoneNumber(phoneNumber: phoneNumber, captchaCode: nil, completion: {
           (captcha, errorInfo) in
            if captcha != nil {
                print("captcha code : " + captcha!.base64Image)
            }
            
            completion(captcha, errorInfo)
        })
    }
    
    func requestCallForOtp(phoneNumber: String,
                           completion: @escaping (Captcha?, PhoneCallResult?, ErrorDetail?) -> Void) {
        
        self.otpRequestedPhoneNumber = phoneNumber
        
        authenticationService.requestPhoneCallForOtpCode(phoneNumber: phoneNumber, captchaCode: nil) { (captcha, callResult, error) in
            if (callResult == nil) {
                completion(captcha, nil, error)
            } else {
                completion(nil, callResult, nil)
            }
        }
    }
    
    func getAccountStatus(userIdentifier: String,
        completion: @escaping (SWDKAccountStatus?, ErrorDetail?) -> Void) {
        self.otpRequestedPhoneNumber = userIdentifier
        authenticationService.getAccountStatus(userIdentifier: userIdentifier, completion: completion)
    }
    
    func getAuthenticationInfo(email: String,
        completion: @escaping (AuthenticationInfo?, ErrorDetail?) -> Void) {
        self.otpRequestedPhoneNumber = email
        authenticationService.getAuthenticationInfo (email: email, completion: completion)
    }
    
    func getOAuthToken(email: String,
                       completion: @escaping (String?, ErrorDetail?) -> Void) {
        authenticationService.getOAuthToken(username: email) { (token, errorInfo) in
            if (token != nil) {
                LoginModel.oAuthTokenMap[email] = token
            }
            completion(token, errorInfo)
        }
    }
    
    func getCacheOAuthToken(email: String) -> String? {
        return LoginModel.oAuthTokenMap[email]
    }
    
    func loginSaml(email: String, activationCode: String,
          completion: @escaping (String?, ErrorDetail?) -> Void) {
        self.otpRequestedPhoneNumber = email
        authenticationService.authenticateWithSaml(email: email, pin: activationCode , completion: completion)
      }
    
    func cancelOtpVerifyProcess() {
        otpRequestedPhoneNumber = nil
    }

    func isOtpWaiting() -> Bool {
        return otpRequestedPhoneNumber != nil
    }

    func verifyOtp(otpCode: String, completion: @escaping (_ account: Account?, _ error: ErrorDetail?) -> Void) {
        if (otpRequestedPhoneNumber != nil) {
            authenticationService.verifyOtp(phoneNumber: otpRequestedPhoneNumber!, otpCode: otpCode) { (accountInfo, errorInfo) in
                self.processCallbackResult(account: accountInfo, error: errorInfo, completion: completion)
            }
        }
    }
    
    func activateAccounChecking(email: String, otpCode: String, completion: @escaping (_ authenInfo: AuthenticationInfo?, _ error: ErrorDetail?) -> Void) {
            authenticationService.activateAccountChecking(userIdentifier: email, pin: otpCode) { (authenInfo, errorInfo) in
                completion(authenInfo, errorInfo)
            }
    }
    
    func activateAccountUsingOtp(phone:String, otpCode: String, completion: @escaping (_ accountId: String?, _ error: ErrorDetail?) -> Void) {
        otpRequestedPhoneNumber = phone.normalizationPhoneNumber()
        if (otpRequestedPhoneNumber != nil) {
            authenticationService.activateAccount(userIdentifier: otpRequestedPhoneNumber!, password: "", pin: otpCode) { (accountInfo, errorInfo) in
                self.accountId = accountInfo
                completion(accountInfo, errorInfo)
            }
        }
    }

    func loadOrganizationList(id: String,
                              callback: @escaping (_ organizations: Array<Organization>?, _ error: ErrorDetail?) -> Void) {
        self.accountId = id
        SWDK.sharedInstance().organizationService().getOrganizations(accountId: id) { (organizations, error) in
            if (error == nil) {
                self.organizations = organizations;
                
                if organizations != nil && organizations!.count > 0 {
                    self.organizations!.sort(by: { (org1, org2) -> Bool in
                        org1.name < org2.name
                    })
                }
            }
            callback(organizations, error)
        }
    }

    func loginWithGoogleOauthToken(email: String,
        idToken: String,
        completion: @escaping (_ account: Account?, _ error: ErrorDetail?) -> Void) {
        authenticationService.authenticateWithGoogleOauthToken(email: email,
            googleToken: idToken) { (accountInfo, errorInfo) in
            self.processCallbackResult(account: accountInfo, error: errorInfo, completion: completion)
        }
    }

    fileprivate func loadCredentialWithNormalMode(_ callback: @escaping ([Credential]?, ErrorDetail?) -> Void) {
        credentialService.getCachedCredentials{ (credentials, error) in
            //ignore error when get cached data
            if (credentials != nil) {
                self.credentialList = credentials!
            }
            callback(credentials, nil)
        }
    }

// TrustIssuer_Use
// TrustIssuer_Use    fileprivate func loadCredentialWithTrustedIssuerMode(_ callback: @escaping (Array<Credential>?, ErrorDetail?) -> Void) {
// TrustIssuer_Use        print("===========getListImportCredential==============")
// TrustIssuer_Use        trustedIssuerService.listImportedCredentials { credentials, errorDetail in
// TrustIssuer_Use            if errorDetail != nil {
// TrustIssuer_Use                callback(nil, errorDetail!)
// TrustIssuer_Use                return
// TrustIssuer_Use            }
// TrustIssuer_Use            self.credentialList = credentials
// TrustIssuer_Use            callback(credentials, nil)
// TrustIssuer_Use        }
// TrustIssuer_Use    }
// TrustIssuer_Use
    func loadCredentials(callback: @escaping (_ credentials: Array<Credential>?, _ error: ErrorDetail?) -> Void) { // TrustIssuer_Use
        loadCredentialWithNormalMode(callback) // TrustIssuerNotUse
// TrustIssuer_Use        loadCredentialWithTrustedIssuerMode(callback)
    } // TrustIssuer_Use

    func accountIsLogged() -> Bool {
        return try! sessionManager.isSessionValid()
    }

    func getSDKInfo() -> SdkInfo {
        return try! sessionManager.getInfo()
    }

// TrustIssuer_Use
// TrustIssuer_Use    //init trusted issuer mode
// TrustIssuer_Use    func initTrustedIssuerModel(callback: @escaping (ErrorDetail?) -> Void) {
// TrustIssuer_Use        print("===========initTrustedIssuerModel==============")
// TrustIssuer_Use        var dataImport = ""
// TrustIssuer_Use        if let path = Bundle.main.path(forResource: "TrustedIssuerJsonData", ofType: "dat") {
// TrustIssuer_Use            do {
// TrustIssuer_Use                dataImport = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
// TrustIssuer_Use            } catch {
// TrustIssuer_Use                print("Failed to read text from resource data")
// TrustIssuer_Use            }
// TrustIssuer_Use        }
// TrustIssuer_Use
// TrustIssuer_Use        TrustIssuerDevelopmentKit.SWDK.sharedInstance().trustedIssuerInitialize(trustedIssuerData: dataImport,
// TrustIssuer_Use                                                                                applicationUUID: SWDKConstant.appUUID) { errorDetail in
// TrustIssuer_Use            if (errorDetail != nil){
// TrustIssuer_Use                callback(errorDetail)
// TrustIssuer_Use                return
// TrustIssuer_Use            }
// TrustIssuer_Use            callback(nil)
// TrustIssuer_Use        }
// TrustIssuer_Use    }
// TrustIssuer_Use
// TrustIssuer_Use    func validateAndImportData(data: String, _ callback: @escaping (Credential?, ErrorDetail?) -> Void) {
// TrustIssuer_Use        print("===========validateAndImportData==============")
// TrustIssuer_Use        trustedIssuerService.validateAndImportCredential(credentialData: data) { credential, errorDetail in
// TrustIssuer_Use            if errorDetail != nil {
// TrustIssuer_Use                callback(nil, errorDetail!)
// TrustIssuer_Use                return
// TrustIssuer_Use            }
// TrustIssuer_Use
// TrustIssuer_Use            callback(credential, nil)
// TrustIssuer_Use        }
// TrustIssuer_Use    }
} // TrustIssuer_Use
