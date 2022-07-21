//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  UIFont+Extend.swift
//  safetrust.swdk.wallet
//
//  Created by safetrust on 8/11/20.
//

import UIKit

extension UIFont {
    
    enum BaseFontName: Int {
        case FONT_NAME_1_REGULAR = 0
        case FONT_NAME_1_BOLD = 1
        case FONT_NAME_1_LIGHT = 2
        case FONT_NAME_2_REGULAR = 10
        case FONT_NAME_2_BOLD = 11
        case FONT_NAME_2_LIGHT = 12

        static func getStringWith(_ type: Int) -> String {
            let result: String;

            switch type {
            case BaseFontName.FONT_NAME_1_REGULAR.rawValue:
                result = "HelveticaNeue"
                break
            case BaseFontName.FONT_NAME_1_BOLD.rawValue:
                result = "HelveticaNeue-Bold"
                break
            case BaseFontName.FONT_NAME_1_LIGHT.rawValue:
                result = "HelveticaNeue-Light"
                break
            case BaseFontName.FONT_NAME_2_REGULAR.rawValue:
                result = "MyriadPro-Regular"
                break
            case BaseFontName.FONT_NAME_2_BOLD.rawValue:
                result = "MyriadPro-Bold"
                break
            case BaseFontName.FONT_NAME_2_LIGHT.rawValue:
                result = "MyriadPro-Light"
                break
            default:
                result = "HelveticaNeue"
            }

            return result
        }
    }
}
