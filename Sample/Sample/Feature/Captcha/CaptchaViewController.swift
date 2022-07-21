//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  CaptchaViewController.swift
//  safetrust.swdk.wallet
//
//  Created by safetrust on 9/7/20.
//

import UIKit
import SafetrustWalletDevelopmentKit

class CaptchaViewController: BaseUIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var captchaCodeTextField: UITextField!
    @IBOutlet weak var captchaImv: UIImageView!
    
    private let authenticationService = SWDK.sharedInstance().authenticationService();
    
    var phoneNumber: String = ""
    public var callback: ((_ captchaCode: String)->())?
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 10
        captchaCodeTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(CaptchaViewController.keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CaptchaViewController.keyboardWillBeHidden),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        
        beginRequestCaptcha()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Action methods
    
    @IBAction func tappedRefreshCaptcha(_ sender: Any) {
        refreshCaptcha()
    }
    
    @IBAction func tappedCancel(_ sender: Any) {
//        dismiss(animated: false, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedSubmit(_ sender: Any) {
        verifyCaptcha()
    }
    
    // MARK: - Keyboard
    
    @objc func keyboardDidShow(notification: Notification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        guard let activeField = captchaCodeTextField, let keyboardHeight = keyboardSize?.height else { return }
        let bottomMargin: CGFloat = 40.0

        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight + bottomMargin, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        let activeRect = activeField.convert(activeField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(activeRect, animated: true)
    }

    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: - Private methods
    
    private func beginRequestCaptcha() {
        showProgressDialog()
        authenticationService.requestOtpCodeForPhoneNumber(phoneNumber: phoneNumber, captchaCode: nil) { (captcha, error) in
            self.hideProgressDialog()
            
            if error != nil {
                self.showErrorDialog(message: error!.code + " - " + error!.message)
                return
            }
            
            if captcha != nil {
                self.captchaImv.image = self.convertByt64ToImage(byt64: captcha!.base64Image)
                self.captchaCodeTextField.text = ""
            }
        }
    }
    
    private func refreshCaptcha() {
        showProgressDialog()
        authenticationService.requestOtpCodeForPhoneNumber(phoneNumber: phoneNumber, captchaCode: "") { (captcha, error) in
            self.hideProgressDialog()
            
            if error != nil {
                self.showErrorDialog(message: error!.code + " - " + error!.message)
                return
            }
            
            if captcha != nil {
                self.captchaImv.image = self.convertByt64ToImage(byt64: captcha!.base64Image)
                self.captchaCodeTextField.text = ""
            }
        }
    }
    
    private func verifyCaptcha() {
        let code: String! = self.captchaCodeTextField.text?.trimmingCharacters(in: .whitespaces)
        
        showProgressDialog()
        authenticationService.requestOtpCodeForPhoneNumber(phoneNumber: phoneNumber, captchaCode: code) { (captcha, error) in
            self.hideProgressDialog()
            
            if error != nil {
                self.showErrorDialog(message: error!.code + " - " + error!.message)
                return
            }
            self.callback?(code)
//            self.dismiss(animated: false, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func convertByt64ToImage(byt64: String) -> UIImage {
        let dataDecoded:NSData = NSData(base64Encoded: byt64, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        
        return decodedimage
    }
}

// MARK: - UITextField delegates

extension CaptchaViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
