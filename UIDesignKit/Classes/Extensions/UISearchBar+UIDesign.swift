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
        dataReturn["tintColor"] = ["type":"COLOR", "value":self.tintColor.toHexString()];
        if let barTintColor = self.barTintColor {
            dataReturn["barTintColor"] = ["type":"COLOR", "value":barTintColor.toHexString()];
        }else{
            dataReturn["barTintColor"] = ["type":"COLOR"];
        }
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "SEARCHBAR";
    }
}
