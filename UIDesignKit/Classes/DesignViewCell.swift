//
//  DesignViewCell.swift
//  Pods
//
//  Created by Will Powell on 08/08/2017.
//
//

import Foundation

class DesignViewCell:UITableViewCell {
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
        
    }
}

class SelectorDesignViewCell:DesignViewCell{
    
}

class IntDesignViewCell:DesignViewCell{
    
}

class FloatDesignViewCell:DesignViewCell{
    
}

class ColorDesignViewCell:DesignViewCell{
    
}
