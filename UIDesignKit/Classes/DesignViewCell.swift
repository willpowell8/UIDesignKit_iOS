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
            self.setup()
        }
    }
    var details:[String:Any]?{
        didSet{
            self.setup()
        }
    }
    
    open func setup(){
        
    }
}

class TextDesignViewCell:DesignViewCell{
    var textField:UITextField?
    override func setup(){
        textField = UITextField()
        textField?.frame = CGRect(x: 270, y: 10, width: 100, height: 20)
        textField?.placeholder = "enter value"
        textField?.textAlignment = .right
        self.addSubview(textField!)
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
