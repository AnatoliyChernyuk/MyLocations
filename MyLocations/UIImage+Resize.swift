//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Anatoliy Chernyuk on 11/22/17.
//  Copyright © 2017 Anatoliy Chernyuk. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = max(horizontalRatio, verticalRatio) //Change the ratio to the maximum one
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(bounds, true, 0) //Cut the image to the given bounds
        let originPoint = CGPoint(x: min((bounds.width - newSize.width), CGPoint.zero.x), y: min((bounds.height - newSize.height), CGPoint.zero.y)) //Calculating origin point to center the image
        draw(in: CGRect(origin: originPoint, size: newSize)) //Using the originPoint
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
