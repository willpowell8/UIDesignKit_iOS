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
    
    @IBOutlet var colorWell:ColorWell?
    @IBOutlet var colorPicker:ColorPicker?
    @IBOutlet var huePicker:HuePicker?
    
    var pickerController:ColorPickerController?
    var selectedColor:UIColor = .black
    
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
            if finished {
                self.view.backgroundColor = UIColor.white // reset background color to white
            }
        }
        self.pickerController?.color = selectedColor
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItems = [cancelButton]
    }
    
    
    func close(){
        self.delegate?.update(color: (pickerController?.color)!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func applyColor(_ color:UIColor){
        selectedColor = color
        self.pickerController?.color = color
    }
    
}
