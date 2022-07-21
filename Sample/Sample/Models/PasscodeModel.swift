//
//  PasscodeModel.swift
//  Sample
//
//  Created by safetrust on 07/04/2022.
//  Copyright © 2022 SafeTrust. All rights reserved.
//

import Foundation

class PasscodeModel {
    
    public enum PasscodeState {
        case none
        case passcode
        case passcode_or_bio
        
        public static func from(index:Int)->PasscodeState{
            switch index {
                case 0:
                    return none
                case 1:
                    return passcode
                case 2:
                    return passcode_or_bio
                default:
                    return none
            }
        }
        
        public func index() ->Int{
            switch self {
                case .none: return 0
                case .passcode: return 1
                case .passcode_or_bio: return 2
            }
        }
    }
    
    public enum PasscodeTimeout {
        case immediately
        case min_01
        case min_02
        case min_03
        /// :nodoc:
        public static func from(index:Int)->PasscodeTimeout{
            switch index {
                case 0:
                    return immediately
                case 1:
                    return min_01
                case 2:
                    return min_02
                case 3:
                    return min_03
                default:
                    return immediately
            }
        }
        
        public func index() ->Int{
            switch self {
                case .immediately: return 0
                case .min_01: return 1
                case .min_02: return 2
                case .min_03: return 3
            }
        }
        
        public func getMins() -> Double {
            switch self {
                case .immediately: return 0.0
                case .min_01: return 5.0
                case .min_02: return 10.0
                case .min_03: return 20.0
            }
        }
        
        public func getString() -> String {
            switch self {
                case .immediately: return NSLocalizedString("PASSCODE_TIMEOUT_IMMEDIATELY", comment: "")
                case .min_01: return NSLocalizedString("PASSCODE_TIMEOUT_TIME_1", comment: "")
                case .min_02: return NSLocalizedString("PASSCODE_TIMEOUT_TIME_2", comment: "")
                case .min_03: return NSLocalizedString("PASSCODE_TIMEOUT_TIME_3", comment: "")
            }
        }
    }
}
