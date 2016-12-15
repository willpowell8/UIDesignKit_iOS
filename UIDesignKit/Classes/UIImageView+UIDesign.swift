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
    override public func getProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getProperties(data: data);
        dataReturn["url"] = ["type":"URL"];
        return dataReturn;
    }
    
    override public func getType() -> String{
        return "IMAGE";
    }
}
