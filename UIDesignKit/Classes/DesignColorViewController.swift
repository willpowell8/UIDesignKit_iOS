//
//  DesignColorViewController.swift
//  Pods
//
//  Created by Will Powell on 13/08/2017.
//
//

import UIKit
import Foundation
import UIKit
import QuartzCore

protocol DesignColorViewControllerDelegate : class{
    func update(color: UIColor)
}

enum GRADIENT {
    case horizontal
    case vertical
}

class DesignColorViewController: UIViewController{
    weak var delegate: DesignColorViewControllerDelegate?
    
    var colorWell:ColorWell?
    var colorPicker:ColorPicker?
    var huePicker:HuePicker?
    
    var pickerController:ColorPickerController?
    var selectedColor:UIColor = .black
    
    var alphaLabel:UILabel?
    var alphaSlider:UISlider?
    var alphaValue:UILabel?
    
    var hexLabel:UILabel?
    var hexText:UITextField?
    var rLabel:UILabel?
    var rText:UITextField?
    var gLabel:UILabel?
    var gText:UITextField?
    var bLabel:UILabel?
    var bText:UITextField?
    
    var property:String? {
        didSet{
            self.navigationItem.title = self.property
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.barStyle = .default
        colorWell = ColorWell(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
        self.view.addSubview(colorWell!)
        
        colorWell?.translatesAutoresizingMaskIntoConstraints = false
        colorWell?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        colorWell?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        colorWell?.heightAnchor.constraint(equalToConstant: 60).isActive = true
        colorWell?.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        hexLabel = UILabel()
        self.view.addSubview(hexLabel!)
        hexLabel?.text = "Hex Value:"
        hexLabel?.translatesAutoresizingMaskIntoConstraints = false
        hexLabel?.textAlignment = .left
        hexLabel?.leftAnchor.constraint(equalTo: self.colorWell!.rightAnchor, constant: 5).isActive = true
        hexLabel?.topAnchor.constraint(equalTo: self.colorWell!.topAnchor, constant: 0).isActive = true
        hexLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        hexLabel?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        hexText = UITextField()
        self.view.addSubview(hexText!)
        hexText?.placeholder = "eg . #FFFFFF"
        hexText?.translatesAutoresizingMaskIntoConstraints = false
        hexText?.leftAnchor.constraint(equalTo: self.hexLabel!.rightAnchor, constant: 5).isActive = true
        hexText?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        hexText?.topAnchor.constraint(equalTo: self.hexLabel!.topAnchor, constant: 0).isActive = true
        hexText?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        hexText?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        hexText?.addTarget(self, action: #selector(didChangeTextfield), for: UIControlEvents.editingChanged)
        
        
        /*valueLabel?.widthAnchor.constraint(equalToConstant: 40).isActive = true
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
        }*/
        
        huePicker = HuePicker(frame: CGRect(x: 0, y: 300, width: 100, height: 100))
        self.view.addSubview(huePicker!)
        huePicker?.translatesAutoresizingMaskIntoConstraints = false
        huePicker?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        huePicker?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        huePicker?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        huePicker?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        colorPicker = ColorPicker(frame: CGRect(x: 0, y: 200, width: 100, height: 100))
        self.view.addSubview(colorPicker!)
        colorPicker?.translatesAutoresizingMaskIntoConstraints = false
        colorPicker?.topAnchor.constraint(equalTo: colorWell!.bottomAnchor, constant: 10).isActive = true
        colorPicker?.bottomAnchor.constraint(equalTo: huePicker!.topAnchor, constant: -30).isActive = true
        colorPicker?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        colorPicker?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        colorPicker?.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        pickerController = ColorPickerController(svPickerView: colorPicker!, huePickerView: huePicker!, colorWell: colorWell!)
        pickerController?.color = UIColor.red
        pickerController?.onColorChange = {(color, finished) in
            self.hexText?.text = color.toShortHexString()
            if finished {
                self.view.backgroundColor = UIColor.white // reset background color to white
            }
        }
        applyColor(self.selectedColor)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItems = [cancelButton]
    }
    
    func didChangeTextfield(){
        if let colorStr = self.hexText?.text, colorStr.characters.count == 7 {
           let color = UIColor(fromHexString: colorStr)
            self.applyColor(color)
        }
    }
    
    
    func close(){
        self.delegate?.update(color: (pickerController?.color)!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func applyColor(_ color:UIColor){
        selectedColor = color
        self.hexText?.text = color.toShortHexString()
        self.pickerController?.color = color
    }
    
}
