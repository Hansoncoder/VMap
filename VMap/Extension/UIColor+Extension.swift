//
//  UIColor+Extension.swift
//  VMap
//
//  Created by Admin on 5/14/24.
//

import UIKit

extension String {
    var color: UIColor {
        return UIColor(hex: self)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hex = hex
        if hex.hasPrefix("#") {
            hex = hex.replacingOccurrences(of: "#", with: "")
        }
               
        
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

