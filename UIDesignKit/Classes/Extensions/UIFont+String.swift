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
    
    static func fromString(value:String)->UIFont?{
        let parts = value.split{$0 == "|"}.map(String.init)
        var size = CGFloat(9.0)
        if(parts.count > 1){
            if let n = Float(parts[2]) {
                size = CGFloat(n)
            }
        }
        let descriptor = UIFontDescriptor(name: parts[0], size: size)
        let font = UIFont(descriptor: descriptor, size: size);
        return font
    }
}
