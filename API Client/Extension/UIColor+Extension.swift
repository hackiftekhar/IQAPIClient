//
//  UIColor+Extension.swift
//  API Client
//
//  Created by Iftekhar on 05/02/21.
//  Copyright © 2021 Iftekhar. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(hex: String) {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    var isLight: Bool {
        let originalCGColor = self.cgColor
        // Now we need to convert it to the RGB colorspace.
        // UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing
        // components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(),
                                                   intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return true
        }
        guard components.count >= 3 else {
            return true
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > 0.5)
    }
}
