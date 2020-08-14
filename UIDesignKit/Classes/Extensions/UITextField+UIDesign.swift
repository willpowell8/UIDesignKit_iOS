//
//  UITextField+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 26/11/2016.
//
//

import Foundation
import SDWebImage

extension UITextField{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data)
        self.applyData(data: data, property: "tintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.tintColor = v
            }
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
            let lightColor = colorForTrait(color: self.tintColor, trait: .light)
            let darkColor = colorForTrait(color: self.tintColor, trait: .dark)
            dataReturn["tintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["tintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }else{
            dataReturn["tintColor"] = ["type":"COLOR", "value":self.tintColor.toHexString()]
        }
        dataReturn["font"] = ["type":"FONT", "value": font?.toDesignString() ?? ""]
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "TEXTFIELD";
    }
}
