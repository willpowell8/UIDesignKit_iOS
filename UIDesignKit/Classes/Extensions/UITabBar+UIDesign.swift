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
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.tintColor, trait: .light)
            let darkColor = colorForTrait(color: self.tintColor, trait: .dark)
            dataReturn["tintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["tintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }else{
            dataReturn["tintColor"] = ["type":"COLOR", "value":self.tintColor.toHexString()]
        }
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "TABBAR";
    }
}
