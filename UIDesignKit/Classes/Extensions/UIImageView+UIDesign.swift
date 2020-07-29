//
//  UIImageView+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 22/11/2016.
//
//

import Foundation
import SDWebImage

extension UIImageView{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "url", targetType: .url, apply: { (value) in
            if let url = value as? URL {
                self.sd_setImage(with: url)
            }
        })
        
        self.applyData(data: data, property: "contentMode", targetType: .int, apply: { (value) in
            if let v = value as? Int, let contentModeVal = UIView.ContentMode(rawValue:v)  {
                self.contentMode = contentModeVal
            }
        })
        
        self.applyData(data: data, property: "tintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.tintColor = v
            }
        })
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        dataReturn["url"] = ["type":"URL"];
        dataReturn["contentMode"] = ["type":"INT", "value": self.contentMode.rawValue];
        
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
        return "IMAGE";
    }
}
