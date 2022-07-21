//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  GlobalData.swift
//  safetrust.swdk.wallet
//
//  Created by safetrust on 8/26/20.
//

import Foundation
import SafetrustWalletDevelopmentKit

class SWDKGlobalData {
    public static var account: User = User()
    public static var credentialList: [Credential] = []
    public static var simulateCrashingInBG: Bool = false
}
