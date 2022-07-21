//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

class CredentialTableViewCell: UITableViewCell {

    @IBOutlet weak var buildingSystemName: UILabel!
    @IBOutlet weak var autoAuthenticate: UILabel!
    @IBOutlet weak var credentialImage: UIImageView!
    @IBOutlet weak var credentialNameLabel: UILabel!
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var statusColorView: UIView!
    @IBOutlet weak var wrapCell: UIView!
    @IBOutlet weak var infoViewGroup: UIView!
    @IBOutlet weak var exportCredential: UIButton!
    @IBOutlet weak var readerName: UILabel!
    @IBOutlet weak var expireTime: UILabel!
    @IBOutlet weak var activeTime: UILabel!
    @IBOutlet weak var autoAuthenticateSwitch: UISwitch!

    var itemId: String = ""
    var viewController: BaseUIViewController? = nil
    var changeAutoAuthen : ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  
    func bindData(credential: Credential) {
        itemId = credential.id
        readerName.isHidden = true
        buildingSystemName.text = credential.identitySystemName
        autoAuthenticate.text = credential.autoAuthenticate
        autoAuthenticateSwitch.isOn = credential.autoAuthenticate != "Off";
        autoAuthenticateSwitch.isEnabled = credential.autoAuthenticateChangeable;
        credentialNameLabel.text = credential.organizationName
        personalName.text = credential.userIdentifier
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy HH:mm"
        if (credential.expireTime > 0) {
            let expireDay = Date(timeIntervalSince1970: TimeInterval(credential.expireTime/1000))
            expireTime.text = dateFormatterPrint.string(from: expireDay)
        } else {
            expireTime.text = SWDKConstant.MESSAGE_CREDENTIAL_NEVER_EXPIRED
        }
        if (credential.effectiveTime > 0){
            let activeDay = Date(timeIntervalSince1970: TimeInterval(credential.effectiveTime/1000))
            activeTime.text = dateFormatterPrint.string(from: activeDay)
        } else {
            activeTime.text = SWDKConstant.MESSAGE_CREDENTIAL_ACTIVATED
        }
        statusColorView.layer.cornerRadius = statusColorView.frame.size.width / 2
        credentialImage.layer.cornerRadius = 18
        credentialImage.loadFromPath(imagePath: credential.frontImagePath, placeHolder: UIImage(named: "blank-card")!) { _ in
            
        }

        exportCredential.isEnabled = credential.isSupportPassDesign
    }

    func updateStatusColor(credentialProximity: CredentialProximity?) {
        if (credentialProximity == nil) {
            statusColorView.backgroundColor = UIColor.clear
            return
        }
        var proximityColor = UIColor.gray
        if (credentialProximity == CredentialProximity.authenticationZone) {
            proximityColor = UIColor.green
        } else if (credentialProximity == CredentialProximity.deviceZone) {
            proximityColor = UIColor.yellow
        }
        statusColorView.backgroundColor = proximityColor
    }

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.4
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }

    @IBAction func onExportCredentialClick(sender:Any) {
        viewController?.showProgressDialog()
        SWDK.sharedInstance().credentialService().exportCredentialToExternalWallet(credentialId: itemId) { (result,error) in
            self.viewController?.hideProgressDialog()
            let message = SWDKConstant.MESSAGE_EXPORT_CREDENTIAL + "\(result)"
            self.makeToast(message: message, duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
        }
       
    }
    
    @IBAction func onAutoAuthenSwitch(sender:Any) {
        do {
            let result = try SWDK.sharedInstance().credentialService().enableAutoAuthentication(credentialId: itemId, enabled: autoAuthenticateSwitch.isOn)
            if(result == CredentialResult.success){
                self.makeToast(message: "auto authen change Success", duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
                changeAutoAuthen?(autoAuthenticateSwitch.isOn)
            } else {
                self.makeToast(message: "auto authen change Failed", duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
            }
        } catch {
            self.makeToast(message: "auto authen change Failed", duration: HRToastDefaultDuration, position: HRToastPositionTop as AnyObject)
        }
    }
}
