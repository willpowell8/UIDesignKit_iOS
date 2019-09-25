//
//  UISegmentControl+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 22/05/2017.
//
//

import Foundation
extension UISegmentedControl{
    override open func updateDesign(type:String, data:[AnyHashable: Any]) {
        super.updateDesign(type:type, data: data);
        self.applyData(data: data, property: "tintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.tintColor = v
            }
        })
        self.applyData(data: data, property: "normalFont", targetType: .font) { (value) in
            if let v = value as? UIFont {
                self.setTitleTextAttributes([NSAttributedString.Key.font: v],
                                                        for: .normal)
            }
        }
        
        self.applyData(data: data, property: "selectedFont", targetType: .font) { (value) in
            if let v = value as? UIFont {
                self.setTitleTextAttributes([NSAttributedString.Key.font: v],
                                            for: .selected)
            }
        }
        
        if #available(iOS 13.0, *) {
            self.applyData(data: data, property: "selectedSegmentTintColor", targetType: .color, apply: { (value) in
                if let v = value as? UIColor {
                    self.selectedSegmentTintColor = v
                }
            })
        }
    }
    override open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = super.getDesignProperties(data: data);
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.tintColor, trait: .light)
            let darkColor = colorForTrait(color: self.tintColor, trait: .dark)
            dataReturn["tintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["tintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }else{
            dataReturn["tintColor"] = ["type":"COLOR", "value":self.tintColor.toHexString()];
        }
        let normalFontAttributes = self.titleTextAttributes(for: .normal)
        if let font = normalFontAttributes?[NSAttributedString.Key.font] as? UIFont {
            dataReturn["normalFont"] = ["type":"FONT", "value":font.toDesignString()];
        }else{
            dataReturn["normalFont"] = ["type":"FONT"]
        }
        let selectedFontAttributes = self.titleTextAttributes(for: .selected)
        if let font = selectedFontAttributes?[NSAttributedString.Key.font] as? UIFont {
            dataReturn["selectedFont"] = ["type":"FONT", "value":font.toDesignString()];
        }else{
            dataReturn["selectedFont"] = ["type":"FONT"]
        }
        
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.selectedSegmentTintColor, trait: .light)
            let darkColor = colorForTrait(color: self.selectedSegmentTintColor, trait: .dark)
            dataReturn["selectedSegmentTintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["selectedSegmentTintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }
        return dataReturn;
    }
    
    @objc override public func getDesignType() -> String{
        return "SEGMENTCONTROL";
    }
}
