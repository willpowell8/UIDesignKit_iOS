//
//  UIColor+Hex.swift
//  Pods
//
//  Created by Will Powell on 15/12/2016.
//
//

import Foundation
import UIKit

extension UIColor {
    public convenience init(fromHexString hexStr:String) {
        var hexString:String = hexStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        var alpha = CGFloat(1.0);
        let hexStringParts = hexString.split{$0 == "|"}.map(String.init)
        hexString = hexStringParts[0]
        if hexStringParts.count > 1 {
            let part2 = hexStringParts[1]
            if let n = Float(part2) {
                alpha = CGFloat(n)
            }
        }
        let scanner            = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = min(1,max(0,CGFloat(r) / 255.0))
        let green = min(1,max(0,CGFloat(g) / 255.0))
        let blue  = min(1,max(0,CGFloat(b) / 255.0))
        alpha = min(1,max(0,alpha))
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    public func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)+"|\(a)"
    }
    
    public func toShortHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
