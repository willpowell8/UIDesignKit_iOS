//
//  UITabBar+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 07/08/2017.
//
//

import Foundation
extension UITabBar{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "tintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.tintColor = v
            }
        })
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        dataReturn["tintColor"] = ["type":"COLOR", "value":self.tintColor.toHexString()];
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "TABBAR";
    }
}
