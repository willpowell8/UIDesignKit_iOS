//
//  UIFont+String.swift
//  Pods
//
//  Created by Will Powell on 15/12/2016.
//
//

import Foundation
import UIKit

extension UIFont {
    func toDesignString() -> String {
        return "\(self.fontName)|\(self.familyName)|\(self.pointSize)"
    }
    
    func toDesignDisplayString() -> String {
        return "\(self.fontName) \(self.pointSize)"
    }
    
    static func fromString(value:String)->UIFont?{
        let parts = value.split{$0 == "|"}.map(String.init)
        var size = CGFloat(9.0)
        if(parts.count > 1){
            if let n = Float(parts[2]) {
                size = CGFloat(n)
            }
        }
        let fontName = parts[0]
        if #available(iOS 13, *) {
            guard fontName != "", fontName != ".SFUIText", fontName != ".SFUIRegular" else {
                return UIFont.systemFont(ofSize: size)
            }
            if fontName == ".SFUIDisplay-Ultralight" {
                return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.ultraLight)
            }
            if fontName == ".SFUIText-Semibold" {
                return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
            }
            if fontName == ".SFUIText-Bold" {
                return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
            }
            if fontName == ".SFUIText-Medium"{
                return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
            }
        }
        let descriptor = UIFontDescriptor(name: fontName, size: size)
        let font = UIFont(descriptor: descriptor, size: size);
        return font
    }
}
