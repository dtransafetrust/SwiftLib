//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import Foundation
import SafetrustWalletDevelopmentKit

extension SystemLogViewController {

    func currentTicks() -> Int64 {
        return Int64(Date().timeIntervalSince1970) * 1000
    }

    func lastMonthTicks() -> Int64 {
        let miliSecondEachDay: Int64 = 86400000
        let dayEachMonth: Int64 = 30
        
        return currentTicks() - (miliSecondEachDay * dayEachMonth)
    }

    func buildLogMessage(log: Event) -> String {
        var logMessage = "-----------------------------\n"
        logMessage.append("\(log.timestamp) \n")
        logMessage.append("\(log.username) -> \(log.readerName) -> \(log.action)\n")
        logMessage.append("\(log.request) -> \(log.response)\n")
        return logMessage
    }
}
