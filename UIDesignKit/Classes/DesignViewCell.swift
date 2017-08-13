//
//  DesignViewCell.swift
//  Pods
//
//  Created by Will Powell on 08/08/2017.
//
//

import Foundation

protocol DesignViewCellDelegate{
    func updateValue(property:String, value:Any)
}

class DesignViewCell:UITableViewCell {
    var delegate:DesignViewCellDelegate?
    var property:String? {
        didSet{
            self.textLabel?.text = property
            self.checkForSetup()
        }
    }
    var details:[String:Any]?{
        didSet{
            self.checkForSetup()
        }
    }
    
    func checkForSetup(){
        if self.property != nil && self.details != nil {
            setup()
        }
    }
    
    open func setup(){
        
    }
}

class TextDesignViewCell:DesignViewCell{
    var textField:UITextField?
    override func setup(){
        textField = UITextField()
        textField?.placeholder = "enter value"
        textField?.textAlignment = .right
        self.addSubview(textField!)
        textField?.translatesAutoresizingMaskIntoConstraints = false
        textField?.leftAnchor.constraint(equalTo: self.textLabel!.leftAnchor, constant: 20).isActive = true
        textField?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
        textField?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textField?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        textField?.addTarget(self, action: #selector(didChangeTextfield), for: UIControlEvents.editingChanged)
        if let details = self.details {
            if let value = details["value"] {
                textField?.text = String(describing:value)
            }
        }
    }
    
    func didChangeTextfield(){
        self.details?["value"] = textField?.text
    }
}

class SelectorDesignViewCell:DesignViewCell{
    
}

class IntDesignViewCell:DesignViewCell{
    var valueLabel:UILabel?
    var slider:UISlider?
    override func setup(){
        valueLabel = UILabel()
        self.addSubview(valueLabel!)
        valueLabel?.translatesAutoresizingMaskIntoConstraints = false
        valueLabel?.textAlignment = .right
        valueLabel?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
        valueLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        valueLabel?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        valueLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        slider = UISlider()
        slider?.minimumValue = 0.0
        slider?.maximumValue = 50.0
        self.addSubview(slider!)
        slider?.translatesAutoresizingMaskIntoConstraints = false
        slider?.rightAnchor.constraint(equalTo: valueLabel!.leftAnchor, constant: -10).isActive = true
        slider?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        slider?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        slider?.widthAnchor.constraint(equalToConstant: 170).isActive = true
        slider?.addTarget(self, action: #selector(didChangeSlider), for: UIControlEvents.valueChanged)
        if let float = self.details?["value"] as? CGFloat {
            slider?.value = Float(float)
            valueLabel?.text = String(describing:getValue())
        }
    }
    
    func getValue()->Int{
        if let sliderV = slider {
            let val = roundf(sliderV.value)
            return Int(val)
        }
        return 0
    }
    
    func didChangeSlider(){
        let newValue = getValue()
        valueLabel?.text = String(describing:getValue())
        if let property = self.property {
            delegate?.updateValue(property: property, value: newValue)
        }
    }
}

class FloatDesignViewCell:DesignViewCell{
    
}

class ColorDesignViewCell:DesignViewCell{
    
}
