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
    public var DesignKey: String? {
        get {
            return objc_getAssociatedObject(self, &designKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &designKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            checkForDesignUpdate()
            setup();
        }
    }
    
    func clear(){
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup(){
        self.clear()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromNotification), name: UIDesign.LOADED, object: nil)
        let eventHighlight = "DESIGN_HIGHLIGHT_\(DesignKey!)"
        NotificationCenter.default.addObserver(self, selector: #selector(highlight), name: NSNotification.Name(rawValue:eventHighlight), object: nil)
        let eventText = "DESIGN_UPDATE_\(DesignKey!)"
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromNotification), name: NSNotification.Name(rawValue:eventText), object: nil)
        
    }
    
    @objc private func updateFromNotification() {
        DispatchQueue.main.async(execute: {
            self.checkForDesignUpdate()
        })
        
    }
    
    
    public func highlight() {
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
                UIDesign.createKey(self.DesignKey!, type:self.getType(), properties: self.getAvailableProperties())
                return;
            }
            let data = design["data"] as! [AnyHashable: Any];
            let type = design["type"] as! String;
            DispatchQueue.main.async(execute: {
                self.updateDesign(type:type, data: data)
            })
        }
    }
    
    private func getAvailableProperties() -> [String:Any] {
        var data = [String:Any]();
        return self.getProperties(data: data);
    }
    
    public func getProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = data;
        dataReturn["backgroundColor"] = ["type":"COLOR", "value":self.backgroundColor?.toHexString()];
        dataReturn["cornerRadius"] = ["type":"INT", "value":self.layer.cornerRadius];
        return dataReturn;
    }
    
    public func getType() -> String{
        return "VIEW";
    }
    
    public func applyData(data:[AnyHashable:Any], property:String, targetType:UIDesignType, apply:@escaping (_ value: Any) -> Void){
        if data[property] != nil {
            let element = data[property] as! [AnyHashable: Any];
            guard let elementType = UIDesignType(rawValue: element["type"] as! String) else {
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
                    if let n = NumberFormatter().number(from: parts[2]) {
                        size = CGFloat(n)
                    }
                    let descriptor = UIFontDescriptor(name: parts[0], size: size)
                    let font = UIFont(descriptor: descriptor, size: size);
                    apply(font);
                    break;
                default:
                    
                    break;
                }
            }else{
                //print("Value is not configured correctly \(elementType)");
            }
        }else{
            // NEED TO ADD PROPERTY
            let properties = self.getAvailableProperties()
            UIDesign.addPropertyToKey(self.DesignKey!, property: property, attribute: properties[property])
        }
    }
    
    public func updateDesign(type:String, data:[AnyHashable: Any]) {
        // OVERRIDE TO GO HERE FOR INDIVIDUAL CLASSES
        self.applyData(data: data, property: "backgroundColor", targetType: .color, apply: { (value) in
            self.backgroundColor = value as! UIColor;
        })
        
        self.applyData(data: data, property: "cornerRadius", targetType: .int, apply: { (value) in
            self.layer.cornerRadius = CGFloat(value as! Int);
        })
    }
}
