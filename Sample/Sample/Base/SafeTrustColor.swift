//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  SafeTrustColor.swift
//  safetrust.swdk.wallet
//
//  Created by safetrust on 7/27/20.
//

import UIKit

class SafeTrustColor {
    public static let PRIMARY_COLOR: UIColor = UIColor(rgb: 0x002741)
    public static let SECOND_COLOR: UIColor = UIColor(rgb: 0xfbc6b0)
    public static let ERROR_COLOR: UIColor = .red
    public static let TITLE_SCREEN_COLOR: UIColor = .black
    
    public static let VALID_TEXT_COLOR: UIColor! = UIColor(rgb: 0x90bdae)
    public static let INVALID_TEXT_COLOR: UIColor! = UIColor(rgb: 0x7c8084)
    public static let GRAY: UIColor! = UIColor(rgb: 0x858585)
    public static let BG_LEFT_MENU: UIColor! = UIColor(rgb: 0xF3F4F5)
    public static let BG_CREDENTIAL_LIST: UIColor = UIColor(rgb: 0x2E4048)
    public static let DEACTIVE_LEFT_MENU: UIColor! = UIColor(rgb: 0x7c8084)
    public static let LIGHT_GRAY: UIColor! = UIColor(rgb: 0xDEDEDE)
    public static let TOAST_SUCCESS_BG_COLOR: UIColor! = UIColor(rgb: 0x1C6C5C)
    public static let TOAST_ERROR_BG_COLOR = ERROR_COLOR
    public static let LONG_PRESS_CARD_BG_COLOR = UIColor.blue
    
    public static let BUTTON_NORMAL_BACKGROUND: UIColor = VALID_TEXT_COLOR
    public static let BUTTON_NORMAL_BORDER_COLOR: UIColor = VALID_TEXT_COLOR
    public static let BUTTON_NORMAL_TEXT_COLOR: UIColor = UIColor.white
    
    public static let BUTTON_ACTIVE_BACKGROUND: UIColor = VALID_TEXT_COLOR
    public static let BUTTON_ACTIVE_BORDER_COLOR: UIColor = VALID_TEXT_COLOR
    public static let BUTTON_ACTIVE_TEXT_COLOR: UIColor = UIColor.white
    
    public static let BUTTON_DEACTIVED_BACKGROUND: UIColor = GRAY
    public static let BUTTON_DEACTIVED_BORDER_COLOR: UIColor = GRAY
    public static let BUTTON_DEACTIVED_TEXT_COLOR: UIColor = UIColor.white
    
    // On Board
    public static let BUTTON_ON_BOARD_BG_COLOR: UIColor = VALID_TEXT_COLOR
    
    // Authenticate View
    public static let TROUBLE_TEXT_COLOR: UIColor = INVALID_TEXT_COLOR
    public static let CONTACT_US_TEXT_COLOR: UIColor = SECOND_COLOR
    
    // Forgot Password View
    public static let FORGOT_PASSWORD_TEXT_COLOR: UIColor = SECOND_COLOR
    
    // Resend Code View
    public static let RESEND_CODE_TEXT_COLOR: UIColor = SECOND_COLOR
    
    // Terms Of Use View
    public static let TEMRS_OF_USE_TEXT_COLOR: UIColor = SECOND_COLOR
    
    // Country Code View
    public static let COUNTRY_CODE_SEARCH_BAR_TINT_COLOR = UIColor(rgb: 0x1c3e53)
    
    // Confirm Your Detail View
    public static let CONFIRM_YOUR_DETAIL_TERMS_TEXT_COLOR = SECOND_COLOR
    
    // Active Code View
    public static let ACTIVE_CODE_BG_COLOR = INVALID_TEXT_COLOR
    public static let ACTIVE_CODE_TEXT_COLOR = INVALID_TEXT_COLOR
    
    // Main Active Code View
    public static let MAIN_ACTIVE_CODE_TEXT_COLOR = INVALID_TEXT_COLOR
    public static let MAIN_ACTIVE_CODE_USERNAME_TEXT_COLOR = SECOND_COLOR
    
    // Setting View
    public static let SETTING_RIGHT_TEXT_COLOR = VALID_TEXT_COLOR
    
    // Acount View
    public static let ACCOUNT_TRANSPARENT_HEADER_BG_COLOR = PRIMARY_COLOR
    public static let ACCOUNT_BOTTOM_MENU_BG_COLOR = PRIMARY_COLOR
    public static let ACCOUNT_ACTIVITIES_TEXT_COLOR = PRIMARY_COLOR
    public static let ACCOUNT_ROLES_TEXT_COLOR = PRIMARY_COLOR
    public static let ACCOUNT_ACCOUNTS_TEXT_COLOR = PRIMARY_COLOR
}
