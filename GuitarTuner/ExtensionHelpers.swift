//
//  ExtensionHelpers.swift
//  GuitarTuner
//
//  Created by Hoang on 12/29/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import UIKit

extension UIColor {
    func rgb() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        var alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let r = CGFloat(red * 255.0)
            let g = CGFloat(green * 255.0)
            let b = CGFloat(blue * 255.0)
            let a = CGFloat(alpha * 255.0)
            
            return (r: r, g: g, b: b, a: a)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
