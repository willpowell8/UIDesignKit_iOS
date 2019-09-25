//
//  UISearchBar+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 22/05/2017.
//
//

import Foundation
extension UISearchBar{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "tintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.tintColor = v
            }
        })
        self.applyData(data: data, property: "barTintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.barTintColor = v
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
        if let barTintColor = self.barTintColor {
            if #available(iOS 13.0, *) {
                let lightColor = colorForTrait(color: barTintColor, trait: .light)
                let darkColor = colorForTrait(color: barTintColor, trait: .dark)
                dataReturn["barTintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
                dataReturn["barTintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
            }else{
                dataReturn["barTintColor"] = ["type":"COLOR", "value":barTintColor.toHexString()];
            }
        }else{
            dataReturn["barTintColor"] = ["type":"COLOR"]
            if #available(iOS 13.0, *) {
                dataReturn["barTintColor-dark"] = ["type":"COLOR"]
            }
        }
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "SEARCHBAR";
    }
}
