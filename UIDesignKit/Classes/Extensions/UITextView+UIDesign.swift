//
//  UITextView+UIDesign.swift
//  UIDesignKit
//
//  Created by Will Powell on 07/07/2020.
//

import Foundation
import SDWebImage

extension UITextView{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data)
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
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data)
        
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.textColor, trait: .light)
            let darkColor = colorForTrait(color: self.textColor, trait: .dark)
            dataReturn["textColor"] = ["type":"COLOR", "value":lightColor?.toHexString()];
            dataReturn["textColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()];
        }else{
            dataReturn["textColor"] = ["type":"COLOR", "value":self.textColor?.toHexString()]
        }
        dataReturn["font"] = ["type":"FONT", "value": font?.toDesignString()]
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "TEXTVIEW";
    }
}
