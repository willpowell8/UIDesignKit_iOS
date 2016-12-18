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
            self.sd_setImage(with: value as! URL);
        })
    }
    override public func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        dataReturn["url"] = ["type":"URL"];
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "IMAGE";
    }
}
