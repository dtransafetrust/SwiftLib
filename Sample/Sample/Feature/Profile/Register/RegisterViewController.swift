//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit
import FlagPhoneNumber

class RegisterViewController: BaseUIViewController {

    private let authenticationService = SWDK.sharedInstance().authenticationService();
    private var phoneCode = "+1"
    var userIdentify: String? = nil

    @IBOutlet weak var phoneOrEmail: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneCodeView: FPNTextField!
    @IBOutlet weak var countryName: UILabel!

    
    @IBAction func doSubmitForm() {
        dismissKeyboard()
        do {
            userIdentify = phoneOrEmail.text
            if(userIdentify!.contains("@")) {
                userIdentify = try phoneOrEmail.validatedText(validationType: ValidatorType.email)
            } else {
                userIdentify = try phoneOrEmail.validatedText(validationType: ValidatorType.phonenumber)
            }
            let firstname = try firstName.validatedText(validationType: ValidatorType.firstname)
            let lastname = try lastName.validatedText(validationType: ValidatorType.lastname)
            registerAccountEmail(
                email: userIdentify!,
                firstName: firstname,
                lastName: lastname,
                countryCode: Int64(phoneCode.replacingOccurrences(of: "+", with: ""))!)
        } catch (let error) {
            showErrorDialog(message: (error as! ValidationError).message)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneOrEmail.text = userIdentify
        view.backgroundColor = UIColor.groupTableViewBackground
        phoneCodeView.borderStyle = .roundedRect
        phoneCodeView.delegate = self
        phoneCodeView.font = UIFont.systemFont(ofSize: 14)
        // Custom the size/edgeInsets of the flag button
        phoneCodeView.flagSize = CGSize(width: 80, height: 40)
        phoneCodeView.flagButtonEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        phoneCodeView.rightView = nil
        phoneCodeView.placeholder = ""
        phoneCodeView.setFlag(for: .US)
      //  view.addSubview(phoneCodeView)
       // phoneCodeView.center = view.center
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if (segue.destination is ActivationViewController) {
            (segue.destination as! ActivationViewController).userIdentify = phoneOrEmail.text
        }
    }
    
    func registerAccountEmail(email: String, firstName: String, lastName: String, countryCode: Int64) {
        print("\n========= start register Account ====\n")
        showProgressDialog()
        authenticationService.registerAccount(
            email: email,
            firstName: firstName,
            lastName: lastName,
            countryCode: countryCode) { (account, error) in
            if (error != nil) {
                //handle on error
                print("\n========= activate Account ====   \(error!.code)")
                self.hideProgressDialog()
                self.showErrorDialog(message: error!.message)
                return;
            }
            self.performSegue(withIdentifier: "show_active_account", sender: nil)
            self.hideProgressDialog()
        }
    }
}

extension RegisterViewController: FPNTextFieldDelegate {
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        textField.placeholder = ""
    }

    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
        phoneCode = dialCode
        countryName.text = name
    }
}
