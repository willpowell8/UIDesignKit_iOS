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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
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
    var roundingFactor = Float(1.0)
    override func setup(){
        valueLabel = UILabel()
        self.addSubview(valueLabel!)
        valueLabel?.translatesAutoresizingMaskIntoConstraints = false
        valueLabel?.textAlignment = .right
        valueLabel?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
        valueLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        valueLabel?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        valueLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        slider = UISlider()
        slider?.minimumValue = 0.0
        slider?.maximumValue = 25.0
        self.addSubview(slider!)
        slider?.translatesAutoresizingMaskIntoConstraints = false
        slider?.rightAnchor.constraint(equalTo: valueLabel!.leftAnchor, constant: -10).isActive = true
        slider?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        slider?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        slider?.widthAnchor.constraint(equalToConstant: 170).isActive = true
        slider?.addTarget(self, action: #selector(didChangeSlider), for: UIControlEvents.valueChanged)
        if let float = self.details?["value"] as? CGFloat {
            slider?.value = Float(float)
            updateDisplay()
        }
    }
    
    func updateDisplay(){
        let newValue = getValue()
        if roundingFactor == 1 {
            let intNewValue = Int(newValue)
            valueLabel?.text = String(describing:intNewValue)
        }else{
            valueLabel?.text = String(describing:newValue)
        }
    }
    
    func getValue()->Float{
        if let sliderV = slider {
            let val = roundf(sliderV.value * roundingFactor)/roundingFactor
            return Float(val)
        }
        return 0
    }
    
    func didChangeSlider(){
        updateDisplay()
        if let property = self.property {
            delegate?.updateValue(property: property, value: getValue())
        }
    }
}

class FloatDesignViewCell:IntDesignViewCell{
    override func setup() {
        self.roundingFactor = Float(10)
        super.setup()
    }
}

class ColorDesignViewCell:DesignViewCell{
    var alphaValueLabel:UILabel?
    var alphaLabel:UILabel?
    var hexValueLabel:UILabel?
    var colorBox:UIView?
    var color:UIColor = .black
    override func setup() {
        super.setup()
        if let colorStr = self.details?["value"] as? String {
            self.color = UIColor(fromHexString:colorStr)
        }
        self.accessoryType = .disclosureIndicator
        alphaValueLabel = UILabel()
        alphaValueLabel?.text = String(describing:self.color.cgColor.alpha)
        self.addSubview(alphaValueLabel!)
        alphaValueLabel?.translatesAutoresizingMaskIntoConstraints = false
        alphaValueLabel?.textAlignment = .right
        alphaValueLabel?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -37).isActive = true
        alphaValueLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        alphaValueLabel?.widthAnchor.constraint(equalToConstant: 23).isActive = true
        alphaValueLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        alphaLabel = UILabel()
        alphaLabel?.text = "alpha:"
        self.addSubview(alphaLabel!)
        alphaLabel?.translatesAutoresizingMaskIntoConstraints = false
        alphaLabel?.textAlignment = .right
        alphaLabel?.rightAnchor.constraint(equalTo: self.alphaValueLabel!.leftAnchor, constant: -5).isActive = true
        alphaLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        alphaLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        hexValueLabel = UILabel()
        hexValueLabel?.text = self.color.toShortHexString().uppercased()
        self.addSubview(hexValueLabel!)
        hexValueLabel?.translatesAutoresizingMaskIntoConstraints = false
        hexValueLabel?.textAlignment = .left
        hexValueLabel?.rightAnchor.constraint(equalTo: self.alphaLabel!.leftAnchor, constant: -10).isActive = true
        hexValueLabel?.widthAnchor.constraint(equalToConstant: 80).isActive = true
        hexValueLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        hexValueLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        colorBox = UIView()
        colorBox?.backgroundColor = self.color
        self.addSubview(colorBox!)
        colorBox?.translatesAutoresizingMaskIntoConstraints = false
        colorBox?.rightAnchor.constraint(equalTo: self.hexValueLabel!.leftAnchor, constant: -5).isActive = true
        colorBox?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        colorBox?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        colorBox?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func updateDisplay(){
        
    }
}

class FontDesignViewCell:DesignViewCell{
    override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator
    }
}
