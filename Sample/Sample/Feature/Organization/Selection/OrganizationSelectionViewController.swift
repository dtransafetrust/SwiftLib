//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class OrganizationSelectionViewController: BaseUIViewController, UITableViewDataSource, UIKit.UITableViewDelegate {

    private let authenticationService = SWDK.sharedInstance().authenticationService();
    private let sessionManager = SWDK.sharedInstance().sessionManager();
    private let credentialService = SWDK.sharedInstance().credentialService()
    private let organizationService = SWDK.sharedInstance().organizationService()
    
    private let loginModel = LoginModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: Array<Organization>? = nil
    var accountId: String? = nil
    var selectedOrganization = Set<Organization>()
    var mCredentialList: Array<Credential>? = nil
    private let cellId = "Organization_cell"

    @IBAction func signOut() {
        try! sessionManager.signOutAndClearSession()
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        performLoginToOrganization(organizations: selectedOrganization)
    }

    func performLoginToOrganization(organizations: Set<Organization>) {
        if (organizations.count == 0) {
            showErrorDialog(message: SWDKConstant.MESSAGE_SELECT_ORGANIZATION)
            return
        }
        if (accountId == nil) {
            // Throw error here
            return;
        }
        showProgressDialog()
        var requestCount = organizations.count
        var validUserSession = false
        organizations.forEach { (Organization) in

        authenticationService.selectOrganization(
                    accountId: accountId!,
                    organizationId: Organization.id) { (error) in

                if (error != nil) {
                    requestCount -= 1
                    if (requestCount <= 0) {
                        if (validUserSession) {
                            self.startSession()
                        } else {
                            self.hideProgressDialog()
                        }
                    }
                    return;
                }

                validUserSession = true
                requestCount -= 1
                if (requestCount <= 0) {
                    if (validUserSession) {
                        self.startSession()
                    } else {
                        self.hideProgressDialog()
                    }
                }
            };
        }
    }

    func startSession() {
        sessionManager.startSession { (error) in
            self.loadCredentialList()
        }
    }
    
    func loadCredentialList() {
        credentialService.getCredentials { (creds, error) in
            if (error != nil) {
                // show the error here
                self.hideProgressDialog()
                return
            }
            self.mCredentialList = creds!
            self.performSegue(withIdentifier: "show_credential_list", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is CredentialListViewController) {
            (segue.destination as! CredentialListViewController).data = mCredentialList
        }
    }

    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshOrganization()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! OrganizationTableViewCell
        let Organization = data![indexPath.row]
        cell.bindData(organization: Organization)
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Organization = data![indexPath.row]
        if (Organization.limitDevice){
            showLimitDeviceAccessDialog(org: Organization, indexPath: indexPath)
            return
        }
        switch Organization.status {
        case OrganizationStatus.pendingActivation:
            showPendingDialog(org: Organization, indexPath: indexPath)
        default:
            selectedOrganization.insert(data![indexPath.row])
        }
        
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedOrganization.remove(data![indexPath.row])
    }
    
    private func showLimitDeviceAccessDialog(org : Organization, indexPath : IndexPath) {
        self.showErrorDialog(message: SWDKConstant.MESSAGE_SELECT_ORG_HAS_LIMIT_DEVICE)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func showPendingDialog(org : Organization, indexPath : IndexPath){
        let _ = DialogUtils.showDialogDoubleButton(controller: self, title: SWDKConstant.TITLE_ALERT_DIALOG,
                                           message: SWDKConstant.MESSAGE_SELECT_PENDING_ORG)
        { (result) in
            if (result) {
                self.showProgressDialog()
                self.organizationService.acceptInvitation(accountId: self.accountId!, organizationId: org.id, inviteAccepted: result) { (result2, error) in
                    if(error != nil){
                        self.hideProgressDialog()
                        self.showToastMessage(message: "Accept org invitation Failed : " + error!.code)
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        return
                    }
                    self.selectedOrganization.insert(org)
                    self.refreshOrganization();
                }

            } else {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    
    private func refreshOrganization(){
        self.loginModel.loadOrganizationList(id: accountId!) { (organizations, error) in
            self.hideProgressDialog()
            if (error != nil) {
                self.showErrorDialog(message: error!.message)
                return
            }
            self.data = organizations
            self.tableView.reloadData()
        }
        loadOrgImageList()
    }
    
    private func loadOrgImageList() {
        organizationService.downloadOrganizationImage(onImageLoaded: { (organization) in
            if let row = self.data?.firstIndex(where: {$0.id == organization.id}) {
                self.data![row].image = organization.image
                self.tableView?.reloadRows(at: [IndexPath.init(row: row, section: 0)], with: UITableView.RowAnimation.fade)
            }
        }) { (error) in
            if error?.message.count ?? 0 > 0 {
                self.showErrorDialog(message: error!.message)
            }
        }
    }
}
