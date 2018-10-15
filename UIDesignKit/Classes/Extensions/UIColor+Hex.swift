//
//  UIColor+Hex.swift
//  Pods
//
//  Created by Will Powell on 15/12/2016.
//
//

import Foundation
import UIKit
private var themeKey: UInt8 = 10
extension UIColor {
    
    public var ThemeKey: String?  {
        get {
            return objc_getAssociatedObject(self, &themeKey) as? String
        }
        set(newValue) {
            design_ThemeClear()
            if(newValue?.isDesignStringAcceptable == false){
                if UIDesign.debug {
                    var str = "UIDESIGN ERROR: key contans invalid characters must be a-z,A-Z,0-9 and . only"
                    if let v = newValue {
                        str = "UIDESIGN ERROR: \(v)"
                    }
                    print(str)
                }
                return;
            }
            
            objc_setAssociatedObject(self, &themeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            if newValue != nil {
                design_ThemeSetup()
                design_apply()
            }
        }
    }
    
    func design_ThemeClear(){
        NotificationCenter.default.removeObserver(self, name: UIDesign.LOADED, object: nil);
        guard let themeKey = ThemeKey, !themeKey.isEmpty else {
            return
        }
        let eventText = "THEME_UPDATE_\(themeKey)"
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventText), object: nil);
    }
    
    func design_ThemeSetup(){
        if let key = ThemeKey, !key.isEmpty {
            NotificationCenter.default.addObserver(self, selector: #selector(design_themeUpdatedFromNotifiation), name: UIDesign.LOADED, object: nil)
            let eventText = "THEME_UPDATE_\(key)"
            NotificationCenter.default.addObserver(self, selector: #selector(design_themeUpdatedFromNotifiation), name: NSNotification.Name(rawValue:eventText), object: nil)
        }
    }
    
    func design_themeUpdatedFromNotifiation(){
        design_apply()
    }
    
    func design_apply(){
        if let themeKey = self.ThemeKey, let themeData = UIDesign.getThemeValue(themeKey, type: "COLOR", value: toHexString()), let themeValue = themeData["value"] as? String {
            print("THeme value",themeValue)
        }
    }
    
    public convenience init(fromHexString hexStr:String) {
        var hexString:String = hexStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        var alpha = CGFloat(1.0);
        let hexStringParts = hexString.components(separatedBy: "|")
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
