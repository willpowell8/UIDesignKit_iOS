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
private var designLayoutKey: UInt8 = 10

extension UIView{
    @IBInspectable
    public var designLayout: Bool  {
        get {
            return objc_getAssociatedObject(self, &designLayoutKey) as? Bool ?? true
        }
        set(newValue) {
            objc_setAssociatedObject(self, &designLayoutKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            designSetup();
        }
    }
    
    @IBInspectable
    public var DesignKey: String?  {
        get {
            return objc_getAssociatedObject(self, &designKey) as? String
        }
        set(newValue) {
            self.designClear()
            if(newValue?.isDesignStringAcceptable == false){
                if UIDesign.debug {
                    var str = "UIDESIGN ERROR: key contans invalid characters must be a-z,A-Z,0-9 and . only"
                    if let v = newValue {
                        str = "UIDESIGN ERROR: \(v)"
                    }
                    print(str)
                }
                return;
            }
            
            objc_setAssociatedObject(self, &designKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            checkForDesignUpdate()
            designSetup();
        }
    }
    
    func designClear(){
        design_inlineEditClear()
        NotificationCenter.default.removeObserver(self, name: UIDesign.LOADED, object: nil);
        if let key = DesignKey, !key.isEmpty {
            let eventHighlight = "DESIGN_HIGHLIGHT_\(key)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventHighlight), object: nil);
            let eventText = "DESIGN_UPDATE_\(key)"
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: eventText), object: nil);
        }
    }
    
    func designSetup(){
         if let key = DesignKey, !key.isEmpty {
            NotificationCenter.default.addObserver(self, selector: #selector(designUpdateFromNotification), name: UIDesign.LOADED, object: nil)
            let eventHighlight = "DESIGN_HIGHLIGHT_\(key)"
            NotificationCenter.default.addObserver(self, selector: #selector(designHighlight), name: NSNotification.Name(rawValue:eventHighlight), object: nil)
            let eventText = "DESIGN_UPDATE_\(key)"
            NotificationCenter.default.addObserver(self, selector: #selector(designUpdateFromNotification), name: NSNotification.Name(rawValue:eventText), object: nil)
            design_inlineEditAddGestureRecognizer()
        }
    }
    
    @objc private func designUpdateFromNotification() {
        if Thread.isMainThread {
            self.checkForDesignUpdate()
        }else{
            DispatchQueue.main.async(execute: {
                self.checkForDesignUpdate()
            })
        }
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
            if Thread.isMainThread {
                self.completeCheckForDesignUpdate(type: type, data: data)
            }else{
                DispatchQueue.main.async(execute: {
                    self.completeCheckForDesignUpdate(type: type, data: data)
                })
            }
        }
    }
    
    private func completeCheckForDesignUpdate(type:String, data:[AnyHashable:Any]){
        if UIDesign.ignoreRemote == true {
            return;
        }
        self.updateDesign(type:type, data: data)
    }
    
    private func getAvailableDesignProperties() -> [String:Any] {
        let data = [String:Any]();
        return self.getDesignProperties(data: data);
    }
    
    open func getDesignProperties(data:[String:Any]) -> [String:Any]{
        var dataReturn = data;
        dataReturn["backgroundColor"] = ["type":"COLOR", "value":self.backgroundColor?.toHexString()];
        dataReturn["cornerRadius"] = ["type":"INT", "value":self.layer.cornerRadius];
        if self.layer.borderWidth > 0 {
            dataReturn["borderWidth"] = ["type":"FLOAT", "value":self.layer.borderWidth];
        }else{
            dataReturn["borderWidth"] = ["type":"FLOAT", "value":self.layer.borderWidth];
        }
        if let borderColor = layer.borderColor {
            dataReturn["borderColor"] = ["type":"COLOR", "value":UIColor(cgColor:borderColor).toHexString()];
        }else{
            dataReturn["borderColor"] = ["type":"COLOR"];
        }
        return dataReturn
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
                        case .bool:
                            guard let value = element[propertyForDeviceType] as? Int
                                else{
                                    return;
                            }
                            apply(value==1);
                            break;
                        
                        case .float:
                            guard let value = element[propertyForDeviceType] as? Float
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
                                apply(url)
                            }
                            break;
                    case .font:
                        guard let value = element[propertyForDeviceType] as? String else {
                            print("Font VALUE NOT STRING");
                            return;
                        }
                        guard let font = UIFont.fromString(value: value) else{
                            return
                        }
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
    
    open func updateDesign(type:String, data:[AnyHashable: Any]) {
        // OVERRIDE TO GO HERE FOR INDIVIDUAL CLASSES
        self.applyData(data: data, property: "backgroundColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.backgroundColor = v
            }
        })
        
        self.applyData(data: data, property: "borderColor", targetType: .color, apply: { (value) in
            if let v = value as? UIColor {
                self.layer.borderColor = v.cgColor
            }
        })
        self.applyData(data: data, property: "borderWidth", targetType: .float, apply: { (value) in
            if let v = value as? Float {
                self.layer.borderWidth = CGFloat(v)
            }
        })
        
        self.applyData(data: data, property: "cornerRadius", targetType: .int, apply: { (value) in
            if let v = value as? Int {
                self.layer.cornerRadius = CGFloat(v);
                if v > 0 {
                    self.clipsToBounds = true
                }
            }
        })
    }
    
    
    /// Inline Edit Gesture Recognizer Add
    func design_inlineEditAddGestureRecognizer(){
        if UIDesign.allowInlineEdit {
            DispatchQueue.main.async {
                self.isUserInteractionEnabled = true
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.design_inlineEditorGestureLongPress(_:)))
                longPressRecognizer.accessibilityLabel = "LONG_DESIGN"
                self.addGestureRecognizer(longPressRecognizer)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(design_inlineEditStateUpdate), name: UIDesign.INLINE_EDIT_CHANGED, object: nil)
    }
    
    /// Inline Editor - gesture recognize Long Press
    func design_inlineEditorGestureLongPress(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == .began, sender.view == self {
            let inline = DesignInlineEditorHandler()
            inline.showAlert(view: self)
        }
    }
    
    /// Inline Edit State Update
    func design_inlineEditStateUpdate(){
        if UIDesign.allowInlineEdit {
            DispatchQueue.main.async {
                self.isUserInteractionEnabled = true
                var hasListener = false
                if let recognizers = self.gestureRecognizers {
                    for recognizer in recognizers {
                        if recognizer.accessibilityLabel == "LONG_DESIGN" {
                            hasListener = true
                        }
                    }
                }
                if hasListener == false {
                    self.design_inlineEditAddGestureRecognizer()
                }
            }
            
        }
    }
    
    func design_inlineEditClear(){
        NotificationCenter.default.removeObserver(self, name: UIDesign.INLINE_EDIT_CHANGED, object: nil);
        if let recognizers = self.gestureRecognizers {
            for recognizer in recognizers {
                if recognizer.accessibilityLabel == "LONG_DESIGN" {
                    self.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
}
