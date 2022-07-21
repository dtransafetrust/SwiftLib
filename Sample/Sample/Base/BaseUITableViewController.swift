//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit

open class BaseUITableViewController: UITableViewController {
    var indicator: UIActivityIndicatorView? = nil

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func progressDialog() {
        let transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator!.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        indicator!.center = view.center
        indicator!.transform = transform
        indicator!.color = .blue
        view.addSubview(indicator!)
        indicator!.bringSubviewToFront(view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    open override func viewDidAppear(_ animated: Bool) {
        registerErrorReceiver()
        registerEnterBackground()
        registerActiveFromBackground()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        unregisterErrorReceiver()
        removeEnterBackground()
        removeActiveFromBackground()
    }
    
    override func enterBackground() {
        checkToShowPasscode()
    }

    func showProgressDialog() {
        progressDialog()
        indicator!.startAnimating()
    }

    func hideProgressDialog() {
        indicator!.stopAnimating()
    }

    func showToastMessage(message: String) {
        self.view.window?.showToast(message: message)
    }

    func showErrorDialog(message: String) {
        self.view.showDialogSingleButton(controller: self, title: "Oops", message: message)
    }
}
