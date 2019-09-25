//
//  UIButton+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 26/11/2016.
//
//

import Foundation
import SDWebImage

extension UIButton{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "tintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.tintColor = v
            }
        })
        
        self.applyData(data: data, property: "textColorNormal", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.setTitleColor(v, for: .normal)
            }
        })
    
        self.applyData(data: data, property: "font", targetType: .font) { (value) in
            if let v = value as? UIFont {
                self.titleLabel?.font = v
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
        self.titleColor(for: .normal)
        if let textNormalColor = self.titleColor(for: .normal) {
            dataReturn["textColorNormal"] = ["type":"COLOR", "value":textNormalColor.toHexString()];
        }else{
            dataReturn["textColorNormal"] = ["type":"COLOR"]
        }
        if let fontString = titleLabel?.font.toDesignString() {
            dataReturn["font"] = ["type":"FONT", "value":fontString];
        }else{
            dataReturn["font"] = ["type":"FONT"]
        }
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "BUTTON";
    }
}
