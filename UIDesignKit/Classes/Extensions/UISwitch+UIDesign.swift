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
        dataReturn["onTintColor"] = ["type":"COLOR", "value":self.onTintColor?.toHexString()];
        dataReturn["thumbTintColor"] = ["type":"COLOR", "value":self.thumbTintColor?.toHexString()];
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "SWITCH";
    }
}
