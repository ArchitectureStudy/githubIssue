//
//  UIColor+extension.swift
//  GithubIssues
//
//  Created by Leonard on 2017. 9. 12..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit

extension UIColor {
    static var opened: UIColor {
        return UIColor(red: 131/255, green: 189/255, blue: 71/255, alpha: 1)
    }
    
    static var closed: UIColor {
        return UIColor(red: 176/255, green: 65/255, blue: 32/255, alpha: 1)
    }
    
}

extension UIColor {
    public func toImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(self.cgColor)
            context.fill(rect)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return image
            }
        }
        return UIImage()
    }
}
