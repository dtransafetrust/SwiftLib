//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class CredentialHelper {

    func authenticateManual(credentialId: Int64, completion: @escaping (_ authResult: DeviceAuthenticationEvent?, _ error: ErrorDetail?) -> Void) {
        SWDK.sharedInstance().scanningService().authenticateManual(credentialId: credentialId, completion: completion);
    }

    func unregisterAuthenticationEvent() {
        do {
            try SWDK.sharedInstance().leashingService().unregisterAuthenticationEvent()
            try SWDK.sharedInstance().scanningService().unregisterAuthenticationEvent()
        } catch {
            // ignore the error
        }
    }

    func loadCredentialImage(credentials: Array<Credential>, onImageLoaded: @escaping (Credential) -> Void) {
        SWDK.sharedInstance().credentialService()
            .downloadCredentialImage(credentials: credentials, onImageLoaded: { (credential) in
                let foundItem = credentials.first(where: { (item) -> Bool in
                    return item.id == credential.id
                }) ?? credential
                foundItem.frontImagePath = credential.frontImagePath
                foundItem.backImagePath = credential.backImagePath
                print("font image path: \(foundItem.frontImagePath)")
                onImageLoaded(foundItem)
            }, completion: { (error) in
                    // Ignore
                })
    }

    func getScanningStatus() -> Bool {
        return try! SWDK.sharedInstance().scanningService().getScanningStatus()
    }
    
    func checkBluetooth(_ controller: BaseUIViewController) {
        do {
            let isBLEEnable = try SWDK.sharedInstance().configurationService().getBluetoothAdapterStatus()
            if !isBLEEnable {
                let _ = DialogUtils.showBaseDialog(controller: controller,
                                                   title: "",
                                                   message: SWDKConstant.ERROR_NEED_BLUETOOTH,
                                                   positiveButton: SWDKConstant.btnOk,
                                                   negativeButton: SWDKConstant.BUTTON_SETTINGS) { (isPositive) in
                    if !isPositive {
                        let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
                        UIApplication.shared.openURL(url!)
                    }
                }
            }
        } catch {
        }
    }
}
