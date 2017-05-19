//
//  UIView+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 22/11/2016.
//
//

import Foundation
import ObjectiveC

private var designKey: UInt8 = 9

extension UIView{
    @IBInspectable
    public var DesignKey: String?  {
        get {
            return objc_getAssociatedObject(self, &designKey) as? String
        }
        set(newValue) {
            self.designClear()
            if(newValue?.isDesignStringAcceptable == false){
                print("UIDESIGN ERROR: key contans invalid characters must be a-z,A-Z,0-9 and . only")
                return;
            }
            
            objc_setAssociatedObject(self, &designKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            checkForDesignUpdate()
            designSetup();
        }
    }
    
    func designClear(){
        NotificationCenter.default.removeObserver(self, name: UIDesign.LOADED, object: nil);
        if DesignKey != nil && (DesignKey?.characters.count)! > 0 {
            let eventHighlight = "DESIGN_HIGHLIGHT_\(DesignKey!)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventHighlight), object: nil);
            let eventText = "DESIGN_UPDATE_\(DesignKey!)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventText), object: nil);
        }
    }
    
    func designSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(designUpdateFromNotification), name: UIDesign.LOADED, object: nil)
        let eventHighlight = "DESIGN_HIGHLIGHT_\(DesignKey!)"
        NotificationCenter.default.addObserver(self, selector: #selector(designHighlight), name: NSNotification.Name(rawValue:eventHighlight), object: nil)
        let eventText = "DESIGN_UPDATE_\(DesignKey!)"
        NotificationCenter.default.addObserver(self, selector: #selector(designUpdateFromNotification), name: NSNotification.Name(rawValue:eventText), object: nil)
        
    }
    
    @objc private func designUpdateFromNotification() {
        DispatchQueue.main.async(execute: {
            self.checkForDesignUpdate()
        })
        
    }
    
    
    public func designHighlight() {
        DispatchQueue.main.async(execute: {
            let originalCGColor = self.layer.backgroundColor
            UIView.animate(withDuration: 0.4, animations: {
                self.layer.backgroundColor = UIColor.red.cgColor
            }, completion: { (okay) in
                UIView.animate(withDuration: 0.4, delay: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.layer.backgroundColor = originalCGColor
                }, completion: { (complete) in
                    
                })
            })
        })
    }
    
    private func checkForDesignUpdate(){
        if ((self.DesignKey?.isEmpty) != nil)  {
            guard let design = UIDesign.get(self.DesignKey!) else {
                UIDesign.createKey(self.DesignKey!, type:self.getDesignType(), properties: self.getAvailableDesignProperties())
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
        dataReturn["backgroundColor"] = ["type":"COLOR", "value":self.backgroundColor?.toHexString()];
        dataReturn["cornerRadius"] = ["type":"INT", "value":self.layer.cornerRadius];
        return dataReturn;
    }
    
    public func getDesignType() -> String{
        return "VIEW";
    }
    
    public func applyData(data:[AnyHashable:Any], property:String, targetType:UIDesignType, apply:@escaping (_ value: Any) -> Void){
        if data[property] != nil {
            let element = data[property] as! [AnyHashable: Any];
            if let elementT = element["type"] as? String {
                guard let elementType = UIDesignType(rawValue: elementT) else {
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
                            
                            let color = UIColor(hexString:value);
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
                        let parts = value.characters.split{$0 == "|"}.map(String.init)
                        var size = CGFloat(9.0)
                        if(parts.count > 1){
                            if let n = NumberFormatter().number(from: parts[2]) {
                                size = CGFloat(n)
                            }
                        }
                        let descriptor = UIFontDescriptor(name: parts[0], size: size)
                        let font = UIFont(descriptor: descriptor, size: size);
                        apply(font);
                        break;
                    default:
                        
                        break;
                    }
                }
            }
        }else{
            // NEED TO ADD PROPERTY
            let properties = self.getAvailableDesignProperties()
            if let attribute = properties[property] {
                UIDesign.addPropertyToKey(self.DesignKey!, property: property, attribute: attribute)
            }
        }
    }
    
    public func updateDesign(type:String, data:[AnyHashable: Any]) {
        // OVERRIDE TO GO HERE FOR INDIVIDUAL CLASSES
        self.applyData(data: data, property: "backgroundColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.backgroundColor = v
            }
        })
        
        self.applyData(data: data, property: "cornerRadius", targetType: .int, apply: { (value) in
            self.layer.cornerRadius = CGFloat(value as! Int);
        })
    }
}
