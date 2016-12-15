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
    override public func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        
    }
    override public func getProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getProperties(data: data);
        //dataReturn["url"] = ["type":"URL"];
        return dataReturn;
    }
    
    override public func getType() -> String{
        return "TEXTFIELD";
    }
}
