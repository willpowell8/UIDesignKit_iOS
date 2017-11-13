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
        
        
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        dataReturn["tintColor"] = ["type":"COLOR", "value":self.tintColor.toHexString()];
        self.titleColor(for: .normal)
        if let textNormalColor = self.titleColor(for: .normal) {
            dataReturn["textColorNormal"] = ["type":"COLOR", "value":textNormalColor.toHexString()];
        }else{
            dataReturn["textColorNormal"] = ["type":"COLOR"]
        }
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "BUTTON";
    }
}
