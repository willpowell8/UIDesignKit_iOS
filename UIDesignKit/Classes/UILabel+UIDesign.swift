//
//  UILabel+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 26/11/2016.
//
//

import Foundation
import SDWebImage

extension UILabel{
    override public func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "textColor", targetType: .color, apply: { (value) in
            self.textColor = value as! UIColor;
        })
        
        self.applyData(data: data, property: "font", targetType: .font, apply: {(value) in
            self.font = value as! UIFont;
        })
        
    }
    override public func getProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getProperties(data: data);
        dataReturn["textColor"] = ["type":"COLOR", "value":self.textColor.toHexString()];
        dataReturn["font"] = ["type":"FONT", "value": font.toDesignString()];
        return dataReturn;
    }
    
    override public func getType() -> String{
        return "LABEL";
    }
}
