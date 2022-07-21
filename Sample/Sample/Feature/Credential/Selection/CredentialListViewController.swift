//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class CredentialListViewController: BaseUIViewController, UITableViewDataSource, UIKit.UITableViewDelegate {

    private let scanningService = SWDK.sharedInstance().scanningService()
    private let leashingService = SWDK.sharedInstance().leashingService()
    private let sessionManager = SWDK.sharedInstance().sessionManager()
    private let credentialService = SWDK.sharedInstance().credentialService()
    private let configurationService = SWDK.sharedInstance().configurationService();


    private var refresh = UIRefreshControl()
    private var isReaderConnected: Bool = false
    private var readerConnected: String = ""

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanningButton: UIButton!
    @IBOutlet weak var crashAppButton: UIButton!
    @IBOutlet weak var crashAppBGButton: UIButton!
    @IBOutlet weak var systemLogButton: UIView!
    @IBOutlet weak var showBioButton: UIView!
    @IBOutlet weak var showAccountButton: UIButton!
    
    @IBAction func logout() {
        let _ = DialogUtils.showDialogDoubleButton(controller: self, title: "",
            message: SWDKConstant.MESSAGE_SIGN_OUT) { (value) in
            if (value) {
                self.clearSessionAndSignout()
            }
        }
    }

    @IBAction func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let credentialId = data![indexPath[1]].id
                if(isReaderConnected) {
                    self.showDialogWarningDisconnectDevice(credentialId: Int64(credentialId)!)
                } else {
                    self.authenticateManual(credentialId: Int64(credentialId)!)
                }
            }
        }
    }

    @IBAction func onScanningChange(_ sender: Any) {
        let status = credentialHelper.getScanningStatus()
        scanningService.enableScanning(enabled: !status, completion: { (error) in
            if (error != nil) {
                let _ = self.handleError(error: error)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
                self.updateScanningEvent()
            }
            
        })
    }
    
    @IBAction func onShowBio(_ sender: Any) {
        configurationService.verifyBiometric(message: "Test Validate Biometric", completion: { (error) in
                print("validate biometric result : " + (error?.code ?? ""))
        })
    }
    
    @IBAction func onCrashApp(_ sender: Any) {
        fatalError()
    }
    
    @IBAction func onCrashAppBG(_ sender: Any) {
        SWDKGlobalData.simulateCrashingInBG = true;
    }

    var data: Array<Credential>? = nil
    var ledStatus: Array<CredentialRangingEvent>? = nil
    private var statusColorDic = Dictionary<String, CredentialProximity>()
    private let credentialHelper = CredentialHelper()
    private let cellId = "credential_view_cell"

    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UIScreen.main.bounds.width * 2048 / 1280
        scanningButton.layer.cornerRadius = 8
        crashAppButton.layer.cornerRadius = 8
        crashAppBGButton.layer.cornerRadius = 8
        systemLogButton.layer.cornerRadius = 8
        showBioButton.layer.cornerRadius = 8
        showAccountButton.layer.cornerRadius = 8
        loadCredentialImage()

        //Pull to refresh
        refresh.attributedTitle = NSAttributedString(string: "Refresh data")
        refresh.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresh)
        
        try! sessionManager.registerSignOutEvent { () in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
               self.clearSessionAndSignout()
            }
        }
        
        try! sessionManager.registerSessionCallbackEvent(callback: { sessionStatus in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
                self.clearSessionAndSignout()
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        credentialHelper.checkBluetooth(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerAuthenticationEvent()
        registerCredentialRangingChangeEvent()

        //Reset Led & Status Credentials
        updateScanningEvent()

        if(data?.count == 0) {
            refreshData(useLocal: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let credentialInfo = data![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CredentialTableViewCell
        cell.bindData(credential: credentialInfo)
        cell.updateStatusColor(credentialProximity: statusColorDic[credentialInfo.id])
        cell.viewController = self
        cell.changeAutoAuthen = { enable in
            credentialInfo.autoAuthenticate = enable ? "On" : "Off";
        }
        return cell
    }

    fileprivate func getCredentialWithNormalMode() {
        credentialService.getCredentials { (creds, error) in
            if (error != nil) {
                return
            }
            self.data = creds
            self.tableView.reloadData()
        }
    }
    
    fileprivate func getCachedCredentialWithNormalMode(){
        credentialService.getCachedCredentials{ (creds, error) in
            if (error != nil) {
                return
            }
            self.data = creds
            self.tableView.reloadData()
        }
    }

// TrustIssuer_Use    fileprivate func getCredentialWithTrustedIssuerMode() {
// TrustIssuer_Use        let trustedIssuerService = SWDK.sharedInstance().trustedIssuerService()
// TrustIssuer_Use        trustedIssuerService.listImportedCredentials { credentials, errorDetail in
// TrustIssuer_Use            if errorDetail != nil {
// TrustIssuer_Use                return
// TrustIssuer_Use            }
// TrustIssuer_Use            self.data = credentials
// TrustIssuer_Use            self.tableView.reloadData()
// TrustIssuer_Use        }
// TrustIssuer_Use    }

    @objc func refreshData(useLocal :Bool = false) {
        if useLocal { // TrustIssuerNotUse
            getCachedCredentialWithNormalMode() // TrustIssuerNotUse
        } else { // TrustIssuerNotUse
            getCredentialWithNormalMode() // TrustIssuerNotUse
        } // TrustIssuerNotUse
// TrustIssuer_Use        getCredentialWithTrustedIssuerMode()
        
        refresh.endRefreshing()
        loadCredentialImage()
    }
    
    @IBAction func tappedShowAccount(_ sender: Any) {
        performSegue(withIdentifier: "show_account_view", sender: self)
    }
    
    private func loadCredentialImage() {
        if (data == nil) {
            return
        }
        credentialHelper.loadCredentialImage(credentials: data!, onImageLoaded: { (credential) in
            let targetItem = self.data?.first(where: { (item) -> Bool in
                return item.id == credential.id
            })
            if (targetItem != nil){
                targetItem?.frontImagePath = credential.frontImagePath
                targetItem?.backImagePath = credential.backImagePath
                let index = self.data?.index(of: targetItem!) ?? 0
                self.tableView?.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: UITableView.RowAnimation.fade)
            }
        })
    }

    private func authenticateManual(credentialId: Int64) {
        CredentialHelper().authenticateManual(credentialId: credentialId) { (event, error) in
            if(error != nil) {
                let _ = self.handleError(error: error)
                return
            }
            self.performShakeCredential(credentialId: "\(credentialId)")
        }
    }

    private func registerAuthenticationEvent() {
        try! leashingService.registerAuthenticationEvent() { (deviceAuthenticationEvent) in
            if(deviceAuthenticationEvent != nil) {
                self.handelAuthenticationEventResult(event: deviceAuthenticationEvent!)
            }
        }

        try! scanningService.registerAuthenticationEvent() { (deviceAuthenticationEvent) in
            if(deviceAuthenticationEvent != nil) {
                print("HANDLE authentication EVENTS : " + deviceAuthenticationEvent!.credentialId + "====" + deviceAuthenticationEvent!.deviceName);
                self.handelAuthenticationEventResult(event: deviceAuthenticationEvent!)
            }
        }
    }

    private func handelAuthenticationEventResult(event: DeviceAuthenticationEvent) {
        readerConnected = event.deviceName
        if (event.isMesh) {
            self.showToastMessage(message: (SWDKConstant.MESSAGE_MESH_NOTIFICATION + " (" + readerConnected + ")"))
            return
        }
        switch SWDKErrorCode.init(rawValue: Int32(event.result)!)! {
        case SWDKErrorCode.CONNECT:
            isReaderConnected = true
            showReaderConnectedMessage(deviceName: event.deviceName, credentialId: event.credentialId)
            break;
        case SWDKErrorCode.DISCONNECT:
            isReaderConnected = false
            showReaderDisconnectedMessage(deviceName: event.deviceName, credentialId: event.credentialId)
            break;
        case SWDKErrorCode.CREDENTIAL_CERTIFICATE_NOT_EFFECTIVE:
            isReaderConnected = false
            self.showToastMessage(message: (SWDKConstant.MESSAGE_NOT_EFFECT))
            break;
        case SWDKErrorCode.SUCCESS:
            isReaderConnected = false
            self.performShakeCredential(credentialId: event.credentialId)
            self.showToastMessage(message: (SWDKConstant.MESSAGE_OPEN_DOOR_SUCCESSFULL + ": " + readerConnected))
            break
        default:
            self.performShakeCredential(credentialId: event.credentialId)
            self.showToastMessage(message: (SWDKConstant.MESSAGE_OPEN_DOOR_FAILED))
        }
    }

    private func registerCredentialRangingChangeEvent() {
        do {
            try scanningService.registerRangingEvent() { (credentials) in
                self.updateCredentialRangingEvent(ledStatus: credentials)
                self.ledStatus = credentials
            }
        } catch {
            // ignore error
        }
    }

    private func showReaderConnectedMessage(deviceName: String, credentialId: String) {
        let message = SWDKConstant.MESSAGE_CONNECTED_READER + deviceName
        self.showToastMessage(message: message)
        performShakeAndShowMessage(credentialId: credentialId, message: deviceName, isConnected: false)
    }

    private func showReaderDisconnectedMessage(deviceName: String, credentialId: String) {
        let message = SWDKConstant.MESSAGE_DISCONNECTED_READER + deviceName
        self.showToastMessage(message: message)
        performShakeAndShowMessage(credentialId: credentialId, message: deviceName, isConnected: true)
    }

    private func performShakeAndShowMessage(credentialId: String, message: String, isConnected: Bool) {
        let foundCell = tableView?.visibleCells.first(where: { (cell) -> Bool in
            return (cell as! CredentialTableViewCell).itemId == credentialId
        })
        if (foundCell != nil) {
            (foundCell as! CredentialTableViewCell).shake()
            (foundCell as! CredentialTableViewCell).readerName.text = message
            (foundCell as! CredentialTableViewCell).readerName.isHidden = isConnected
        }
    }

    private func showWarningDisconnectingMessage(credentialId: String) {
        let foundCell = tableView?.visibleCells.first(where: { (cell) -> Bool in
            return (cell as! CredentialTableViewCell).itemId == credentialId
        })
        if (foundCell != nil) {
            (foundCell as! CredentialTableViewCell).readerName.isHidden = false
            (foundCell as! CredentialTableViewCell).readerName.text = SWDKConstant.MESSAGE_DISCONNECTING_READER
        }
    }
    
    private func performShakeCredential(credentialId: String) {
        let foundCell = tableView?.visibleCells.first(where: { (cell) -> Bool in
            return (cell as! CredentialTableViewCell).itemId == credentialId
        })
        if (foundCell != nil) {
            (foundCell as! CredentialTableViewCell).shake()
        }
    }

    private func updateCredentialRangingEvent(ledStatus: Array<CredentialRangingEvent>) {
        statusColorDic.removeAll()
        ledStatus.forEach { (item) in
            statusColorDic[item.credentialId] = item.credentialProximity
        }
        tableView?.visibleCells.forEach({ (cell) in
            let item = (cell as! CredentialTableViewCell)
            item.updateStatusColor(credentialProximity: statusColorDic[item.itemId])
        })
    }

    // Update status color after switch Scanning
    private func resetCredentialRangingEvent(ledStatus: Array<CredentialRangingEvent>) {
        statusColorDic.removeAll()
        ledStatus.forEach { (item) in
            statusColorDic[item.credentialId] = nil
        }
        tableView?.visibleCells.forEach({ (cell) in
            let item = (cell as! CredentialTableViewCell)
            item.updateStatusColor(credentialProximity: statusColorDic[item.itemId])
        })
    }

    private func updateScanningEvent() {
        if(credentialHelper.getScanningStatus()) {
            self.scanningButton.setTitle(SWDKConstant.MESSAGE_SCANNING, for: .normal)
        } else {
            self.scanningButton.setTitle(SWDKConstant.MESSAGE_SCAN, for: .normal)
            if ledStatus != nil {
                self.resetCredentialRangingEvent(ledStatus: ledStatus!)
            }
        }
    }

    private func showDialogWarningDisconnectDevice(credentialId: Int64) {
        var message = SWDKConstant.MESSAGE_WARNING_DISCCONNECTED_READER
        message.append(readerConnected)
        message.append("?")
        let _ = DialogUtils.showDialogDoubleButton(controller: self, title: SWDKConstant.TITLE_ALERT_DIALOG,
            message: message)
        { (value) in
            if (value) {
                self.authenticateManual(credentialId: credentialId)
                //show disconnecting
               self.showWarningDisconnectingMessage(credentialId: "\(credentialId)")
            }
        }
    }
    //Clear session and signout all account
    private func clearSessionAndSignout() {
        //reset select trusted issuer mode
        clearUDM()
        credentialHelper.unregisterAuthenticationEvent()
        do {
            try scanningService.unregisterRangingEvent()
            try sessionManager.signOutAndClearSession()
        } catch {
            // ignore the error
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    // Clearing UserDefaults!
    func clearUDM() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
}
