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
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        let dataReturn = super.getDesignProperties(data: data)
        return dataReturn;
    }
    
    override public func getDesignType() -> String{
        return "TEXTFIELD";
    }
}
