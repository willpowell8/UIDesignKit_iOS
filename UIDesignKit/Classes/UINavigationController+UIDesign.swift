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
        if DesignKey != nil && (DesignKey?.count)! > 0 {
            let eventHighlight = "DESIGN_HIGHLIGHT_\(DesignKey!)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventHighlight), object: nil);
            let eventText = "DESIGN_UPDATE_\(DesignKey!)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventText), object: nil);
        }
    }
    
    func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateDesignFromNotification), name: UIDesign.LOADED, object: nil)
        let eventHighlight = "DESIGN_HIGHLIGHT_\(DesignKey!)"
        NotificationCenter.default.addObserver(self, selector: #selector(designHighlight), name: NSNotification.Name(rawValue:eventHighlight), object: nil)
        let eventText = "DESIGN_UPDATE_\(DesignKey!)"
        NotificationCenter.default.addObserver(self, selector: #selector(updateDesignFromNotification), name: NSNotification.Name(rawValue:eventText), object: nil)
        
    }
    
    @objc private func updateDesignFromNotification() {
        DispatchQueue.main.async(execute: {
            self.checkForDesignUpdate()
        })
    }
    
    
    public func designHighlight() {

    }
    
    private func checkForDesignUpdate(){
        if ((self.DesignKey?.isEmpty) != nil)  {
            guard let design = UIDesign.get(self.DesignKey!) else {
                UIDesign.createKey(self.DesignKey!, type:self.getType(), properties: self.getAvailableDesignProperties())
                return;
            }
            let data = design["data"] as! [AnyHashable: Any];
            let type = design["type"] as! String;
            DispatchQueue.main.async(execute: {
                if UIDesign.ignoreRemote == true {
                    return;
                }
                self.updateDesign(type:type, data: data)
            })
        }
    }
    
    private func getAvailableDesignProperties() -> [String:Any] {
        let data = [String:Any]();
        return self.getDesignProperties(data: data);
    }
    
    public func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = data;
        
        dataReturn["barTintColor"] = ["type":"COLOR", "value":self.navigationBar.barTintColor?.toHexString()];
        dataReturn["tintColor"] = ["type":"COLOR", "value":self.navigationBar.tintColor.toHexString()];
        dataReturn["navigationTitleFontColor"] = ["type":"COLOR"];
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
                    let parts = value.split{$0 == "|"}.map(String.init)
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
            if let propertyValue = properties[property] {
                UIDesign.addPropertyToKey(self.DesignKey!, property: property, attribute: propertyValue)
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
                    self.navigationBar.titleTextAttributes = [String:Any]()
                }
                self.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = v
            }
        })
        
        self.applyData(data: data, property: "navigationTitleFont", targetType: .color, apply: { (value) in
            if let v = value as? UIFont {
                if self.navigationBar.titleTextAttributes == nil {
                    self.navigationBar.titleTextAttributes = [String:Any]()
                }
                self.navigationBar.titleTextAttributes?[NSFontAttributeName] = v
            }
        })
    }

}
