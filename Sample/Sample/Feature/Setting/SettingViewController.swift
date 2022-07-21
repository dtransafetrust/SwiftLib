//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class SettingViewController: BaseUITableViewController {
    private let configurationService = SWDK.sharedInstance().configurationService();

    @IBOutlet weak var accessFeedBackCell: UITableViewCell!

    @IBOutlet weak var antiPassBackCell: UITableViewCell!

    @IBOutlet weak var changePasscodeCell: UITableViewCell!

    @IBOutlet weak var leasingToggle: UISwitch!
    
    @IBOutlet weak var leasingTitleLabel: UILabel!
    
    @IBOutlet weak var autoStartToggle:UISwitch!
    
    @IBOutlet weak var debugLogToggle:UISwitch!
    
    @IBOutlet weak var getBeaconStateCell: UITableViewCell!
    
    @IBOutlet weak var bleConnectionTimeoutCell: UITableViewCell!
    
    @IBOutlet weak var meshNotificationToggle:UISwitch!
    
    @IBOutlet weak var beaconWakeUpNotificationToggle:UISwitch!

    @IBOutlet weak var shareLogCell: UITableViewCell!
    
    @IBAction func onLeashingEnableChanged(_ sender: UISwitch) {
        self.showProgressDialog()
        configurationService.enableLeashing(enabled: sender.isOn, completion: { (error) in
            self.hideProgressDialog()
        })
    }

    var configurationInfo: ConfigurationInfo? = nil
    private let accessFeedbackOptions = [SWDKConstant.SILENT, SWDKConstant.VIBRATE, SWDKConstant.BUZZER_VIB]

    func showChangePasscodeInput() {
        let hasPasscode = self.getPasscodeState() != PasscodeModel.PasscodeState.none
        let dialog = UIAlertController(title: SWDKConstant.CHANGE_PASSCODE_MESSAGE, message: nil, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: SWDKConstant.btnCancel,
            style: .cancel))
        if (hasPasscode){
            dialog.addTextField(configurationHandler: { textField in
                textField.placeholder = SWDKConstant.OLD_PASSCODE_PLACE_HOLDER
                textField.keyboardType = UIKeyboardType.numberPad
            })
        }
        dialog.addTextField(configurationHandler: { textField in
            textField.placeholder = SWDKConstant.NEW_PASSCODE_PLACE_HOLDER
            textField.keyboardType = UIKeyboardType.numberPad
        })
        dialog.addTextField(configurationHandler: { textField in
            textField.placeholder = SWDKConstant.CONFIRM_PASSCODE_PLACE_HOLDER
            textField.keyboardType = UIKeyboardType.numberPad
        })
        
        dialog.addAction(UIAlertAction(title: SWDKConstant.btnChange,
        style: .default,
        handler: { action in
            var oldPassData : String!
            var newPassData : String!
            var confirmPassData: String!
            if (hasPasscode){
                oldPassData = dialog.textFields?[0].text
                newPassData = dialog.textFields?[1].text
                confirmPassData = dialog.textFields?[2].text
            } else {
                oldPassData = ""
                newPassData = dialog.textFields?[0].text
                confirmPassData = dialog.textFields?[1].text
            }
            if (hasPasscode && oldPassData.isEmpty){
                self.showToastMessage(message: SWDKConstant.MESSAGE_OLD_PASSCODE_EMPTY)
            } else if(newPassData != confirmPassData){
                self.showToastMessage(message: SWDKConstant.MESSAGE_PASSCODE_NOT_SAME)
            } else {
                var codeResult: Int32 = 0
                codeResult = try! self.configurationService.updatePasscode(oldPasscode: oldPassData!, newPasscode: newPassData!)
                
                if codeResult == SWDKErrorCode.SUCCESS.rawValue {
                    // Verify passcode when setting a new passcode
                    if (!hasPasscode && oldPassData.isEmpty) {
                        self.configurationService.verifyPasscode(passcode: newPassData,
                                                                 completion: { (isVerified, error)  in
                            if(error != nil) {
                                self.notifyPasscodeChange(codeResult: Int32(error!.code)!)
                                return
                            }
                            self.setPasscodeState(.passcode)
                            self.notifyPasscodeChange(codeResult: SWDKErrorCode.SUCCESS.rawValue)
                        })
                        return
                    } else if hasPasscode && !oldPassData.isEmpty && newPassData.isEmpty {
                        self.setPasscodeState(.none)
                    } else {
                        self.setPasscodeState(.passcode)
                    }
                }
                
                self.notifyPasscodeChange(codeResult: codeResult)
            }
        }))
        self.present(dialog, animated: true, completion: nil)
    }

    private func notifyPasscodeChange (codeResult: Int32) {
        switch SWDKErrorCode.init(rawValue: Int32(codeResult))! {
        case SWDKErrorCode.SUCCESS:
            self.showToastMessage(message: SWDKConstant.MESSAGE_PASSCODE_CHANGE_SUCCESSFULL)
            break;
        case SWDKErrorCode.PASSCODE_INVALID:
            self.showToastMessage(message: SWDKConstant.MESSAGE_PASSCODE_CHANGE_INVALID)
            break
        case SWDKErrorCode.TOO_MANY_FAILED_PASSCODE_ATTEMPTS:
            self.showToastMessage(message: SWDKConstant.MESSAGE_PASSCODE_WRONG_MANY_TIMES)
            break
        default:
            self.showToastMessage(message: SWDKConstant.MESSAGE_PASSCODE_CHANGE_INVALID)
            break;
        }
    }

    // Silent 0, Vibrate 1, Buzzer & vibrate 2
    func showAccessFeedbackInput() {
        let currentOption = Int(configurationInfo!.accessFeedback)
        let dialog = DialogUtils.buildPrickerDialog(title: SWDKConstant.CHANGE_ACCESS_FEEDBACK_MESSAGE,
            positiveButton: SWDKConstant.btnChange,
            negativeButton: SWDKConstant.btnCancel,
            selections: accessFeedbackOptions,
            selectionIndex: currentOption,
            handleResult: { (Int) in
                if(Int == currentOption) {
                    return;
                }
                self.configurationInfo!.accessFeedback = Int32(Int)
                try! self.configurationService.updateCredentialAuthenticationFeedback(mode: CredentialAuthenticationFeedback.from(index: Int))
                self.accessFeedBackCell.detailTextLabel?.text = self.accessFeedbackOptions[Int]
            })
        self.present(dialog, animated: true, completion: nil)
    }

    func showAntiPassBackInput() {
        if configurationInfo!.antiPassBackValues.count == 0 {
            self.showToastMessage(message: "Anti Passback list is empty")
            return
        }
        
        let antiPassbackStringList = configurationInfo!.antiPassBackValues.map { String($0) }
        let selectedIndex = configurationInfo!.antiPassBackValues.index(of: self.configurationInfo!.antiPassBack)
        let extendList = extensionWithAntiPassback(antiPassbackStringList)
        
        let dialog = DialogUtils.buildPrickerDialog(title: "Choose an value",
                                       positiveButton: SWDKConstant.btnOk,
                                       negativeButton: SWDKConstant.btnCancel,
                                       selections: extendList,
                                       selectionIndex: selectedIndex!,
                                       alertHeight: 230,
                                       pickerRect: CGRect(x: 5, y: 40, width: 250, height: 150)) { (index) in
            let delay: Double! = Double(self.configurationInfo!.antiPassBackValues[index])

            let result = try! self.configurationService.updateAntiPassback(duration: delay)

            switch SWDKErrorCode.init(rawValue: result)! {
            case SWDKErrorCode.SUCCESS:
                self.antiPassBackCell.detailTextLabel?.text = self.extendAntiPassbackStr("\(delay ?? 0.5)")
                self.configurationInfo!.antiPassBack = delay

            case SWDKErrorCode.ANTIPASSBACK_INVALID:
                self.showToastMessage(message: "not a valid number input")

            case SWDKErrorCode.PASSCODE_NEEDS_TO_BE_SET:
                self.showToastMessage(message: "Need Setup passcode");

            default:
                self.showToastMessage(message: "Change Anti passback failed")
            }
        }
        self.present(dialog, animated: true, completion: nil)
    }
    
    func showBleConnectionTimeout() {
        let timeoutValues = [5, 10, 15, 20, 25, 30]
        
        let selectedIndex = timeoutValues.index(of: Int(self.configurationInfo!.bleConnectionTimeout)) ?? 0
        
        let dialog = DialogUtils.buildPrickerDialog(title: "Choose an value",
                                       positiveButton: SWDKConstant.btnOk,
                                       negativeButton: SWDKConstant.btnCancel,
                                       selections: timeoutValues.map{String($0)},
                                       selectionIndex: selectedIndex,
                                       alertHeight: 230,
                                       pickerRect: CGRect(x: 5, y: 40, width: 250, height: 150)) { (index) in
            let value = Int32(timeoutValues[index])
            
            let result = self.configurationService.setBleConnectionTimeout(seconds: value)
            
            switch SWDKErrorCode.init(rawValue: result)! {
            case SWDKErrorCode.SUCCESS:
                self.bleConnectionTimeoutCell.detailTextLabel?.text = "\(value )"
                self.configurationInfo!.bleConnectionTimeout = value
                
            case SWDKErrorCode.ANTIPASSBACK_INVALID:
                self.showToastMessage(message: "not a valid number input")
                
            case SWDKErrorCode.PASSCODE_NEEDS_TO_BE_SET:
                self.showToastMessage(message: "Need Setup passcode");
                
            default:
                self.showToastMessage(message: "Change BLE Connection timeout failed")
            }
        }
        self.present(dialog, animated: true, completion: nil)
    }

    private enum SETTING_ITEM {
        case NaN // -1
        case LEASING // 0
        case ACCESS_FEADBACK // 1
        case ANTI_PASS_BACK // 2
        case CHANGE_PASS_CODE // 3
        case BLE_CONNECTION_TIMEOUT // 4
        case ENABLE_AUTO_START // 5
        case NOTIFICATION_FOR_MESH // 6
        case NOTIFICATION_FOR_BEACON // 7
        case ENABLE_DEBUG_LOG // 8
        case SHARE_LOG // 9
        case LAUCH_SETTING // 10

        static func from(index: Int) -> SETTING_ITEM {
            switch index {
            case 0: return SETTING_ITEM.LEASING
            case 1: return SETTING_ITEM.ACCESS_FEADBACK
            case 2: return SETTING_ITEM.ANTI_PASS_BACK
            case 3: return SETTING_ITEM.CHANGE_PASS_CODE
            case 4: return SETTING_ITEM.BLE_CONNECTION_TIMEOUT
            case 5: return SETTING_ITEM.ENABLE_AUTO_START
            case 8: return SETTING_ITEM.ENABLE_DEBUG_LOG
            case 9: return SETTING_ITEM.SHARE_LOG
            case 10: return SETTING_ITEM.LAUCH_SETTING
            default: return SETTING_ITEM.NaN
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch SETTING_ITEM.from(index: indexPath.row) {
        case SETTING_ITEM.ACCESS_FEADBACK:
            showAccessFeedbackInput()
            break
        case SETTING_ITEM.ANTI_PASS_BACK:
            showAntiPassBackInput()
            break
        case SETTING_ITEM.CHANGE_PASS_CODE:
            showChangePasscodeInput()
            break
        case SETTING_ITEM.BLE_CONNECTION_TIMEOUT:
            showBleConnectionTimeout()
            break
        case SETTING_ITEM.SHARE_LOG:
            shareLog()
            break
        case SETTING_ITEM.LAUCH_SETTING:
            showSettingPage()
            break
                
        default: break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettingInfo()
    }
    
    override func activeFromBackground() {
        loadSettingInfo()
    }


    func loadSettingInfo() {
        self.showProgressDialog()
        configurationService.getSWDKSetting(asyncResult: { (SettingInfo) in
            self.configurationInfo = SettingInfo
            self.bindUIView()
            self.hideProgressDialog()
        }, onError: { (ErrorDetail) in
                // Ignore
                self.hideProgressDialog()
            })
    }

    private func bindUIView() {
        if(configurationInfo != nil) {
            leasingToggle.isOn = configurationInfo!.leashing
            do {
                let isBLEEnable = try configurationService.getBluetoothAdapterStatus()
                if (isBLEEnable){
                    leasingToggle.isEnabled = true
                    leasingTitleLabel.text = "Leashing"
                } else{
                    leasingTitleLabel.text = "Leashing (Support when enable bluetooth)"
                    leasingToggle.isEnabled = false
                }
            }catch{
                
            }
            debugLogToggle.isOn = configurationInfo!.debugLog
            shareLogCell.isHidden = (configurationInfo!.debugLog != true)
            meshNotificationToggle.isOn = configurationInfo!.showNotificationForMesh
            beaconWakeUpNotificationToggle.isOn = configurationInfo!.showNotificationWhenWakeupFromBeacon
            accessFeedBackCell.detailTextLabel?.text = accessFeedbackOptions[Int(configurationInfo!.accessFeedback)]
            antiPassBackCell.detailTextLabel?.text = "\(configurationInfo!.antiPassBack)"
            changePasscodeCell.isUserInteractionEnabled = true
            changePasscodeCell.textLabel?.isEnabled = true
            showBeaconState()
            bleConnectionTimeoutCell.detailTextLabel?.text = String(configurationInfo!.bleConnectionTimeout)
        }
    }
    
    private func showBeaconState(){
        configurationService.getBeaconAutoStartState() { (result, error) in
            if(error == nil){
                self.autoStartToggle.isOn = (result != BeaconAutoStartState.disabled)
                self.getBeaconStateCell.isHidden = (result != BeaconAutoStartState.needLocationPermission)
            }
            print("Result ====: " + result.index().description);

        }
    }
    
    @IBAction func onBeaconAutoStartEnableChanged(_ sender: UISwitch) {
        self.showProgressDialog()
            configurationService.enableBeaconAutoStart(enabled: sender.isOn,  completion: { (error) in
                self.showBeaconState()
                self.hideProgressDialog()
                print(" beacon auto start Result ===== : ")
            self.hideProgressDialog()
        })
    }
    
    @IBAction func onDebugLogChanged(_ sender: UISwitch) {
        self.showProgressDialog()
        configurationService.enableDebugLog(enabled: sender.isOn, completion: { (error) in
            self.hideProgressDialog()
            self.shareLogCell.isHidden = (sender.isOn != true)
        })
    }
    
    @IBAction func onMeshNotificationChanged(_ sender: UISwitch) {
        self.showProgressDialog()
        configurationService.enableNotificationOnMeshAuthentication(enabled: sender.isOn, completion: { (error) in
            self.hideProgressDialog()
        })
    }
    
    @IBAction func onBeaconWakeupNotificationChanged(_ sender: UISwitch) {
        self.showProgressDialog()
        configurationService.enableNotificationOnBeaconWakeup(enabled: sender.isOn, completion: { (error) in
            self.hideProgressDialog()
        })
    }
    
    // MARK: - Private methods
    
    private func showSettingPage() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func extensionWithAntiPassback(_ strList: Array<String>) -> Array<String> {
        var extendList = Array<String>()
        
        for index in 0...(strList.count-1) {
            let item = strList[index]
            let extendItem = item + " (s)"
            extendList.append(extendItem)
        }
        
        return extendList
    }
    
    private func extendAntiPassbackStr(_ antiPassback: String) -> String {
        let result = antiPassback + " (s)"
        
        return result
    }
    
    private func shareLog() {
        configurationService.shareLog( completion: { (error) in
        })
    }
}
