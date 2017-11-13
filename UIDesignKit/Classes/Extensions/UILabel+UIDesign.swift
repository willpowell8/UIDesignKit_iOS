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
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "textColor", targetType: .color, apply: { (value) in
            self.textColor = value as! UIColor;
        })
        
        self.applyData(data: data, property: "font", targetType: .font, apply: {(value) in
            self.font = value as! UIFont;
        })
        
        self.applyData(data: data, property: "adjustsFontSizeToFitWidth", targetType: .bool, apply: {(value) in
            self.adjustsFontSizeToFitWidth = value as! Bool;
        })
        
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        dataReturn["textColor"] = ["type":"COLOR", "value":self.textColor.toHexString()]
        dataReturn["font"] = ["type":"FONT", "value": font.toDesignString()]
        dataReturn["adjustsFontSizeToFitWidth"] =  ["type":"BOOL", "value": adjustsFontSizeToFitWidth ? 1 : 0]
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "LABEL";
    }
}
