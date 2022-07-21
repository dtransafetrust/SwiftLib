//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  EventLogViewCell.swift
//  safetrust.swdk.wallet
//
//  Created by safetrust on 8/19/20.
//

import UIKit
import SafetrustWalletDevelopmentKit

class EventLogViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var readerNameLabel: CustomLabel!
    @IBOutlet weak var timeLabel: CustomLabel!
    @IBOutlet weak var userNameLabel: CustomLabel!
    @IBOutlet weak var actionLabel: CustomLabel!
    @IBOutlet weak var lineView: UIView!
    
    func setup(_ event: Event) {
        readerNameLabel.text = event.readerName
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM dd yyyy HH:mm:ss"
        
        let eventDate = Date(timeIntervalSince1970: TimeInterval(event.timestampAsTicks/1000))
        timeLabel.text = NSLocalizedString("AT", comment: "") + " \(dateFormatterPrint.string(from: eventDate))"
        
        userNameLabel.text = NSLocalizedString("BY", comment: "") + " \(event.username)"
        actionLabel.text = NSLocalizedString("ACTION", comment: "") + " \(event.action)"
        
        timeLabel.textColor = SafeTrustColor.DEACTIVE_LEFT_MENU
        userNameLabel.textColor = SafeTrustColor.DEACTIVE_LEFT_MENU
        actionLabel.textColor = SafeTrustColor.DEACTIVE_LEFT_MENU
        lineView.backgroundColor = SafeTrustColor.DEACTIVE_LEFT_MENU
    }
}
