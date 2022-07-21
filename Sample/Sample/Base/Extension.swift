//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import UIKit
import SafetrustWalletDevelopmentKit

extension UIViewController {
    func registerEnterBackground() {
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(enterBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
    
    func removeEnterBackground() {
        NotificationCenter.default.removeObserver(self,
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
    
    
    func registerActiveFromBackground(){
        NotificationCenter.default.addObserver(self,
                                       selector: #selector(activeFromBackground),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)
        
    }
    
    func removeActiveFromBackground() {
        NotificationCenter.default.removeObserver(self,
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)
    }
    
    @objc func enterBackground() {
        
    }
    
    @objc func activeFromBackground() {
        
    }
}
