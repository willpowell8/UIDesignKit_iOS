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
    override public func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "url", targetType: .url, apply: { (value) in
            if let url = value as? URL {
                self.sd_setImage(with: url)
            }
        })
        
        self.applyData(data: data, property: "contentMode", targetType: .int, apply: { (value) in
            if let v = value as? Int, let contentModeVal = UIViewContentMode(rawValue:v)  {
                self.contentMode = contentModeVal
            }
        })
    }
    override public func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        dataReturn["url"] = ["type":"URL"];
        dataReturn["contentMode"] = ["type":"INT", "value": self.contentMode.rawValue];
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "IMAGE";
    }
}
