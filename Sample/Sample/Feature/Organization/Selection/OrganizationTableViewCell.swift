//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  OrganizationTableViewCell.swift
//  Sample
//
//  Created by safetrust on 6/17/20.
//
import UIKit
import SafetrustWalletDevelopmentKit

class OrganizationTableViewCell : UITableViewCell {

    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var statusLabel : UILabel!
    @IBOutlet weak var reachLimitLabel : UILabel!
    @IBOutlet weak var icon : UIImageView!
    

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func bindData(organization : Organization ) {
        nameLabel.text = organization.name
        statusLabel.text = organization.status.description()
        reachLimitLabel.isHidden = organization.limitDevice == false
        icon.loadFromPath(imagePath: organization.image, placeHolder: UIImage(named: SWDKConstant.BLANK_ORGANIZATION_IMAGE_STR)!) { _ in
        }
    }
}

