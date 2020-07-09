//
//  UIActivityIndicatorView+UIDesign.swift
//  UIDesignKit
//
//  Created by Will Powell on 09/07/2020.
//

import Foundation
extension UIActivityIndicatorView{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "color", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.color = v
            }
        })
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.color, trait: .light)
            let darkColor = colorForTrait(color: self.color, trait: .dark)
            dataReturn["color"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["color-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }else{
            dataReturn["color"] = ["type":"COLOR", "value":self.color?.toHexString()];
        }
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "ACTIVITYINDICATOR";
    }
}
