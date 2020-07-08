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
        applyData(data: data, property: "tintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.tintColor = v
            }
        })
        applyData(data: data, property: "barTintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.barTintColor = v
            }
        })
        
        if #available(iOS 13.0, *) {
            applyData(data: data, property: "searchBarTextColor", targetType: .color) { (value) in
                if let v = value as? UIColor {
                    self.searchTextField.textColor = v
                    self.searchTextField.leftView?.tintColor = v
                }
            }
            
            applyData(data: data, property: "searchBarBackgroundColor", targetType: .color) { (value) in
                if let v = value as? UIColor {
                    self.searchTextField.backgroundColor = v
                }
            }
        }
        
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
        if #available(iOS 13.0, *) {
            let searchTextFieldHex = (searchTextField.textColor ?? UIColor.black)
            let lightColor = colorForTrait(color: searchTextFieldHex, trait: .light)
            let darkColor = colorForTrait(color: searchTextFieldHex, trait: .dark)
            dataReturn["searchBarTextColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["searchBarTextColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }
        
        if #available(iOS 13.0, *) {
            let searchTextFieldBGHex = (searchTextField.backgroundColor ?? UIColor.white)
            let lightColor = colorForTrait(color: searchTextFieldBGHex, trait: .light)
            let darkColor = colorForTrait(color: searchTextFieldBGHex, trait: .dark)
            dataReturn["searchBarBackgroundColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["searchBarBackgroundColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
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
