//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  AccountViewController.swift
//  Sample
//
//  Created by safetrust on 10/28/20.
//

import UIKit
import SafetrustWalletDevelopmentKit

class AccountViewController: BaseUIViewController {
    
    private let userService = SWDK.sharedInstance().userService()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshAccountData()
    }
    
    // MARK: - Action methods
    
    @IBAction func tappedRefresh(_ sender: Any) {
        refreshAccountData()
    }
    
    // MARK: - Public methods
    
    func refreshAccountData() -> Void {
        
        self.showProgressDialog()
        userService.refreshAll { (error) in
            if error != nil && error!.message.count > 0 {
                self.hideProgressDialog()
                self.handleError(error: error)
                return
            }
                
            self.userService.getActiveUser { (user, error) in
                if error != nil && error!.message.count > 0 {
                    self.hideProgressDialog()
                    self.handleError(error: error)
                    return
                }
                if user != nil {
                    SWDKGlobalData.account = user!
                }
                self.loadDataToView()
            }
            
            self.userService.registerUserAvatarDownloadedEvent(onImageLoaded: { (user) in
                SWDKGlobalData.account = user
//                self.loadImageToView()
                self.hideProgressDialog()
                
            }) { (error) in
                self.hideProgressDialog()
                self.handleError(error: error)
            }
        }
    }
    
    func loadDataToView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0)) {
            let user: User = SWDKGlobalData.account
            
            self.nameLabel.text = "\(user.firstName) \(user.lastName)"
            self.userNameLabel.text = "\(user.username)"
        }
    }
}
