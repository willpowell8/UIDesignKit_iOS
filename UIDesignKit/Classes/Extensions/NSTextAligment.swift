//
//  NSTextAligment.swift
//  UIDesignKit
//
//  Created by Will Powell on 28/10/2018.
//

import Foundation

extension NSTextAlignment {
    static func designConvertAlignment(_ aligment:NSTextAlignment, layout:UIDesignAligment)->NSTextAlignment{
        if layout == .rtl {
            // convert for right to left
            switch(aligment){
            case .left:
                return NSTextAlignment.right
            case .right:
                return NSTextAlignment.left
            case .natural:
                return NSTextAlignment.right
            default:
                return aligment
            }
        } else if layout == .ltr {
            if aligment == .natural {
                return NSTextAlignment.left
            }
        }
        return aligment
    }
}
