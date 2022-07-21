//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  CustomLabel.swift
//  safetrust.swdk.wallet
//
//  Created by safetrust on 7/27/20.
//

import UIKit

@IBDesignable
public class CustomLabel: UILabel {
    
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = NSLocalizedString(key ?? "", comment: "")
        }
    }
    
    @IBInspectable var fontType: Int = UIFont.BaseFontName.FONT_NAME_1_REGULAR.rawValue {
        didSet {
            self.font = UIFont(name: UIFont.BaseFontName.getStringWith(fontType), size: fontSize)
        }
    }

    @IBInspectable var fontSize: CGFloat = 14 {
        didSet {
            self.font = UIFont(name: UIFont.BaseFontName.getStringWith(fontType), size: fontSize)
        }
    }
    
    var insets = UIEdgeInsets.zero
    
    // MARK: - Override methods
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    public override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += insets.top + insets.bottom
            contentSize.width += insets.left + insets.right
            return contentSize
        }
    }
    
    // MARK: - Private methods
    
    private func commonInit() -> Void {
        fontType = UIFont.BaseFontName.FONT_NAME_1_REGULAR.rawValue
        fontSize = 14
    }
    
    // MARK: - Public methods
    
    func padding(_ top: CGFloat, _ bottom: CGFloat, _ left: CGFloat, _ right: CGFloat) {
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width + left + right, height: self.frame.height + top + bottom)
        insets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}
