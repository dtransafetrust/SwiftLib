//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

enum ErrorType: String {
    case toast = "toast"
}

extension UIViewController {

    func handleError(error: ErrorDetail?) -> Bool {
        if(error == nil) {
            return false;
        }
        // TODO next we need to filter error base on business then show right error type
        let msg = error!.code.isEmpty ? error!.message : getErrorMessage(code: error!.code)
        postErrorMessage(message: msg, type: .toast)
        return true
    }

    func registerErrorReceiver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onReceiveErrorData(_:)),
            name: Notification.Name(rawValue: SWDKConstant.ERROR_NOTIFICATION_TAG),
            object: nil)
    }

    func unregisterErrorReceiver() {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: SWDKConstant.ERROR_NOTIFICATION_TAG),
            object: nil)
    }

    @objc private func onReceiveErrorData(_ notification: Notification) {
        if let data = notification.userInfo as? [String: String] {
            let message = data["message"] ?? "Unknow Error"
            let type = ErrorType(rawValue: data["type"] ?? "toast")!
            switch type {
            case ErrorType.toast:
                self.view.showToast(message: message)
                break
            }
        }
    }

    private func postErrorMessage(message: String, type: ErrorType) {
        NotificationCenter.default
            .post(
                name: Notification.Name(rawValue: SWDKConstant.ERROR_NOTIFICATION_TAG),
                object: nil,
                userInfo: ["message": message, "type": type.rawValue])
    }

    private func getErrorMessage(code: String) -> String {
        return "\(SWDKConstant.errorMessageDic[Int32(code)!] ?? "\(SWDKConstant.REQUEST_ERROR) \(code)")"
    }
}
