//
//  UILabel+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 26/11/2016.
//
//

import Foundation
import SDWebImage

extension UILabel{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "textColor", targetType: .color, apply: { (value) in
            guard let c = value as? UIColor else {
                return
            }
            self.textColor = c
        })
        
        self.applyData(data: data, property: "font", targetType: .font, apply: {(value) in
            guard let f = value as? UIFont else {
                return
            }
            self.font = f
        })
        
        self.applyData(data: data, property: "adjustsFontSizeToFitWidth", targetType: .bool, apply: {(value) in
            guard let a = value as? Bool else {
                return
            }
            self.adjustsFontSizeToFitWidth = a
        })
        
        self.applyData(data: data, property: "textAlignment", targetType: .int) { (value) in
            guard let i = value as? Int, var alignment = NSTextAlignment(rawValue: i) else {
                return
            }
            if self.designLayout == true {
                alignment = NSTextAlignment.designConvertAlignment(alignment, layout: UIDesign.layoutAlignment)
            }
            self.textAlignment = alignment
        }
        
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data)
        var alignment = self.textAlignment
        if self.designLayout == true {
            alignment = NSTextAlignment.designConvertAlignment(alignment, layout: UIDesign.layoutAlignment)
        }
        dataReturn["textAlignment"] = ["type":"INT", "value":alignment.rawValue]
        dataReturn["textColor"] = ["type":"COLOR", "value":self.textColor.toHexString()]
        dataReturn["font"] = ["type":"FONT", "value": font.toDesignString()]
        dataReturn["adjustsFontSizeToFitWidth"] =  ["type":"BOOL", "value": adjustsFontSizeToFitWidth ? 1 : 0]
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "LABEL";
    }
}
