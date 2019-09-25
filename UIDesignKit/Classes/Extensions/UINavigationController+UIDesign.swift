//
//  UINavigationController+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 17/12/2016.
//
//

import UIKit

private var designKey: UInt8 = 9

extension UINavigationController {
    
    @IBInspectable
    public var DesignKey: String? {
        get {
            return objc_getAssociatedObject(self, &designKey) as? String
        }
        set(newValue) {
            designClear()
            objc_setAssociatedObject(self, &designKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            checkForDesignUpdate()
            setupNotifications();
        }
    }

    func designClear(){
        NotificationCenter.default.removeObserver(self, name: UIDesign.LOADED, object: nil);
        if let designKey = DesignKey, designKey.count > 0 {
            let eventHighlight = "DESIGN_HIGHLIGHT_\(designKey)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventHighlight), object: nil);
            let eventText = "DESIGN_UPDATE_\(designKey)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventText), object: nil);
        }
    }
    
    func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateDesignFromNotification), name: UIDesign.LOADED, object: nil)
        if let designKey = DesignKey, designKey.count > 0 {
            let eventHighlight = "DESIGN_HIGHLIGHT_\(designKey)"
            NotificationCenter.default.addObserver(self, selector: #selector(designHighlight), name: NSNotification.Name(rawValue:eventHighlight), object: nil)
            let eventText = "DESIGN_UPDATE_\(designKey)"
            NotificationCenter.default.addObserver(self, selector: #selector(updateDesignFromNotification), name: NSNotification.Name(rawValue:eventText), object: nil)
        }
        
    }
    
    @objc private func updateDesignFromNotification() {
        if Thread.isMainThread {
            self.checkForDesignUpdate()
        }else{
            DispatchQueue.main.async(execute: {
                self.checkForDesignUpdate()
            })
        }
    }
    
    
    @objc public func designHighlight() {

    }
    
    private func checkForDesignUpdate(){
        if let designKey = self.DesignKey, !designKey.isEmpty  {
            guard let design = UIDesign.get(designKey) else {
                UIDesign.createKey(designKey, type:self.getType(), properties: self.getAvailableDesignProperties())
                return;
            }
            
            if UIDesign.ignoreRemote == true {
                return;
            }
            guard let data = design["data"] as? [AnyHashable: Any],  let type = design["type"] as? String else{
                return
            }
            if Thread.isMainThread {
                self.updateDesign(type:type, data: data)
            }else{
                DispatchQueue.main.async(execute: {
                    self.updateDesign(type:type, data: data)
                })
            }
        }
    }
    
    private func getAvailableDesignProperties() -> [String:Any] {
        let data = [String:Any]();
        return self.getDesignProperties(data: data);
    }
    
    @available(iOS 13.0, *)
    func colorForTrait(color:UIColor?, trait:UIUserInterfaceStyle)->UIColor?{
        guard color != nil else {
            return nil
        }
        let view = UIView()
        view.overrideUserInterfaceStyle = trait
        view.backgroundColor = color
        guard let c = view.layer.backgroundColor else {
            return nil
        }
        let outputColor = UIColor(cgColor: c)
        return outputColor
    }
    
    public func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = data;
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.navigationBar.barTintColor, trait: .light)
            let darkColor = colorForTrait(color: self.navigationBar.barTintColor, trait: .dark)
            dataReturn["barTintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["barTintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }else{
            dataReturn["barTintColor"] = ["type":"COLOR", "value":self.navigationBar.barTintColor?.toHexString()]
        }
        if #available(iOS 13.0, *) {
            let lightColor = colorForTrait(color: self.navigationBar.tintColor, trait: .light)
            let darkColor = colorForTrait(color: self.navigationBar.tintColor, trait: .dark)
            dataReturn["tintColor"] = ["type":"COLOR", "value":lightColor?.toHexString()]
            dataReturn["tintColor-dark"] = ["type":"COLOR", "value":darkColor?.toHexString()]
        }else{
            dataReturn["tintColor"] = ["type":"COLOR", "value":self.navigationBar.tintColor.toHexString()]
        }
        if #available(iOS 13.0, *) {
            dataReturn["navigationTitleFontColor"] = ["type":"COLOR"]
            dataReturn["navigationTitleFontColor-dark"] = ["type":"COLOR"]
        }else{
            dataReturn["navigationTitleFontColor"] = ["type":"COLOR"]
        }
        dataReturn["navigationTitleFont"] = ["type":"FONT"];
        return dataReturn;
    }
    
    public func getType() -> String{
        return "VIEW";
    }
    
    public func applyData(data:[AnyHashable:Any], property:String, targetType:UIDesignType, apply:@escaping (_ value: Any) -> Void){
        if data[property] != nil {
            let element = data[property] as! [AnyHashable: Any];
            guard let elementTypeString =  element["type"] as? String, let elementType = UIDesignType(rawValue:elementTypeString) else {
                return;
            }
            if element["universal"] != nil && elementType == targetType {
                var propertyForDeviceType:String = "universal";
                if element[UIDesign.deviceType] != nil {
                    propertyForDeviceType = UIDesign.deviceType
                }
                switch(targetType){
                case .color:
                    guard let value = element[propertyForDeviceType] as? String
                        else{
                            return;
                    }
                    
                    let color = UIColor(fromHexString:value);
                    apply(color);
                    break;
                case .int:
                    guard let value = element[propertyForDeviceType] as? Int
                        else{
                            return;
                    }
                    apply(value);
                    break;
                case .url:
                    guard let value = element[propertyForDeviceType] as? String else {
                        print("URL VALUE NOT STRING");
                        return;
                    }
                    if value != "<null>" {
                        guard let url = URL(string:value) else{
                            return;
                        }
                        apply(url);
                    }
                    break;
                case .font:
                    guard let value = element[propertyForDeviceType] as? String else {
                        print("Font VALUE NOT STRING");
                        return;
                    }
                    let parts = value.components(separatedBy: "|")
                    if ( parts.count > 1 ) {
                        var size = CGFloat(9.0)
                        if let n = Float(parts[2]) {
                            size = CGFloat(n)
                        }
                        let descriptor = UIFontDescriptor(name: parts[0], size: size)
                        let font = UIFont(descriptor: descriptor, size: size);
                        apply(font);
                    }
                    break;
                default:
                    
                    break;
                }
            }else{
                //print("Value is not configured correctly \(elementType)");
            }
        }else{
            // NEED TO ADD PROPERTY
            let properties = self.getAvailableDesignProperties()
            if let propertyValue = properties[property], let designKey = self.DesignKey, !designKey.isEmpty {
                UIDesign.addPropertyToKey(designKey, property: property, attribute: propertyValue)
            }
            
        }
    }
    
    public func updateDesign(type:String, data:[AnyHashable: Any]) {
        // OVERRIDE TO GO HERE FOR INDIVIDUAL CLASSES
        self.applyData(data: data, property: "barTintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.navigationBar.barTintColor = v
            }
        })
        self.applyData(data: data, property: "tintColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.navigationBar.tintColor = v
            }
        })
        
        self.applyData(data: data, property: "navigationTitleFontColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                if self.navigationBar.titleTextAttributes == nil {
                    self.navigationBar.titleTextAttributes = [NSAttributedString.Key:Any]()
                }
                self.navigationBar.titleTextAttributes?[NSAttributedString.Key.foregroundColor] = v
            }
        })
        
        self.applyData(data: data, property: "navigationTitleFont", targetType: .font, apply: { (value) in
            if let v = value as? UIFont {
                if self.navigationBar.titleTextAttributes == nil {
                    self.navigationBar.titleTextAttributes = [NSAttributedString.Key:Any]()
                }
                self.navigationBar.titleTextAttributes?[NSAttributedString.Key.font] = v
            }
        })
    }

}
