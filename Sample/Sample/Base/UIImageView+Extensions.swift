//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

//
//  UIImageView+Extensions.swift
//  safetrust.swdk.wallet
//
//  Created by safetrust on 8/19/20.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadFromPath(imagePath: String, placeHolder: UIImage, completion: @escaping (_ cardSize: CGSize) -> Void) {
        self.image = nil
        
        var result: CGSize = CGSize.zero
        
        // check if the image is stored already
        if FileManager.default.fileExists(atPath: imagePath) {
            let imageData: Data = try! Data(contentsOf: URL(fileURLWithPath: imagePath))
            let source = CGImageSourceCreateWithData(imageData as CFData, nil)
            let imageHeader = CGImageSourceCopyPropertiesAtIndex(source!, 0, nil)! as NSDictionary;
            let imageWidth: CGFloat = imageHeader["PixelWidth"] as! CGFloat
            let imageHeight: CGFloat = imageHeader["PixelHeight"] as! CGFloat
            result = CGSize(width: imageWidth, height: imageHeight)
            let count = CGImageSourceGetCount(source!)
            
            if let imageFromCache = imageCache.object(forKey: imagePath as NSString) {
                self.image = imageFromCache
                
                completion(imageFromCache.size)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0)) {
                var imageToCache: UIImage?
                
                if count > 1 { // image is gif type
                    imageToCache = UIImage.gifImageWithData(imageData)!
                } else {
                    imageToCache = UIImage(data: imageData, scale: UIScreen.main.scale)!
                }
                
                imageCache.setObject(imageToCache!, forKey: imagePath as NSString)
                
                self.image = imageToCache
                result = imageToCache!.size
                
                completion(result)
            }
        } else {
            self.image = placeHolder
            result = placeHolder.size
            
            completion(result)
        }
    }
    
    func setCustomTintColor(_ color: UIColor) {
        guard self.image != nil else {
            return
        }
        
        if #available(iOS 13.0, *) {
            self.image = self.image?.withTintColor(color)
        } else {
            // Fallback on earlier versions
            self.image = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.tintColor = color
        }
    }
}
