//
//  UISwitch+UIDesign.swift
//  UIDesignKit
//
//  Created by Will Powell on 10/07/2019.
//

import Foundation
extension UISwitch{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "onTintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.onTintColor = v
            }
        })
        self.applyData(data: data, property: "thumbTintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.thumbTintColor = v
            }
        })
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.onTintColor, trait: .light)
            let darkColor = colorForTrait(color: self.onTintColor, trait: .dark)
            dataReturn["onTintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["onTintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }else{
            dataReturn["onTintColor"] = ["type":"COLOR", "value":self.onTintColor?.toHexString()];
        }
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.thumbTintColor, trait: .light)
            let darkColor = colorForTrait(color: self.thumbTintColor, trait: .dark)
            dataReturn["thumbTintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["thumbTintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }else{
            dataReturn["thumbTintColor"] = ["type":"COLOR", "value":self.thumbTintColor?.toHexString()]
        }
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "SWITCH";
    }
}
