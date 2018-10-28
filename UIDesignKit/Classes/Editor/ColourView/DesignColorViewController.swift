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
    
    var colours = [String]()
    
    var previousCollectionView:UICollectionView?
    
    var property:String? {
        didSet{
            self.navigationItem.title = self.property
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colours = UIDesign.colours
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.barStyle = .default
        colorWell = ColorWell(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
        self.view.addSubview(colorWell!)
        
        colorWell?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            colorWell?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
            colorWell?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
            colorWell?.heightAnchor.constraint(equalToConstant: 60).isActive = true
            colorWell?.widthAnchor.constraint(equalToConstant: 60).isActive = true
        }else{
            // todo
        }
        
        
        hexLabel = UILabel()
        self.view.addSubview(hexLabel!)
        hexLabel?.text = "Hex Value:"
        hexLabel?.translatesAutoresizingMaskIntoConstraints = false
        hexLabel?.textAlignment = .left
        if #available(iOS 9.0, *) {
            hexLabel?.leftAnchor.constraint(equalTo: self.colorWell!.rightAnchor, constant: 5).isActive = true
            hexLabel?.topAnchor.constraint(equalTo: self.colorWell!.topAnchor, constant: 0).isActive = true
            hexLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
            hexLabel?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }else{
            // todo
        }
        
        hexText = UITextField()
        self.view.addSubview(hexText!)
        hexText?.placeholder = "eg . #FFFFFF"
        hexText?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            hexText?.leftAnchor.constraint(equalTo: self.hexLabel!.rightAnchor, constant: 5).isActive = true
            hexText?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
            hexText?.topAnchor.constraint(equalTo: self.hexLabel!.topAnchor, constant: 0).isActive = true
            hexText?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            hexText?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }else{
            // todo
        }
        hexText?.addTarget(self, action: #selector(didChangeTextfield), for: UIControl.Event.editingChanged)
        
        
        rLabel = UILabel()
        self.view.addSubview(rLabel!)
        rLabel?.text = "R:"
        rLabel?.translatesAutoresizingMaskIntoConstraints = false
        rLabel?.textAlignment = .left
        if #available(iOS 9.0, *) {
            rLabel?.leftAnchor.constraint(equalTo: self.colorWell!.rightAnchor, constant: 5).isActive = true
            rLabel?.topAnchor.constraint(equalTo: self.hexLabel!.bottomAnchor, constant: 10).isActive = true
            rLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
            rLabel?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        }else{
            // todo
        }
        rText = UITextField()
        self.view.addSubview(rText!)
        rText?.placeholder = "0-255"
        rText?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            rText?.leftAnchor.constraint(equalTo: self.rLabel!.rightAnchor, constant: 5).isActive = true
            rText?.topAnchor.constraint(equalTo: self.hexLabel!.bottomAnchor, constant: 10).isActive = true
            rText?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            rText?.widthAnchor.constraint(equalToConstant: 60).isActive = true
            rText?.addTarget(self, action: #selector(didChangeRGBTextfield), for: UIControl.Event.editingChanged)
        }else{
                // todo
        }
        gLabel = UILabel()
        self.view.addSubview(gLabel!)
        gLabel?.text = "G:"
        gLabel?.translatesAutoresizingMaskIntoConstraints = false
        gLabel?.textAlignment = .left
        if #available(iOS 9.0, *) {
            gLabel?.leftAnchor.constraint(equalTo: self.rText!.rightAnchor, constant: 5).isActive = true
            gLabel?.topAnchor.constraint(equalTo: self.hexLabel!.bottomAnchor, constant: 10).isActive = true
            gLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
            gLabel?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        }else{
            // todo
        }
        gText = UITextField()
        self.view.addSubview(gText!)
        gText?.placeholder = "0-255"
        gText?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            gText?.leftAnchor.constraint(equalTo: self.gLabel!.rightAnchor, constant: 5).isActive = true
            gText?.topAnchor.constraint(equalTo: self.hexLabel!.bottomAnchor, constant: 10).isActive = true
            gText?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            gText?.widthAnchor.constraint(equalToConstant: 60).isActive = true
        }
        gText?.addTarget(self, action: #selector(didChangeRGBTextfield), for: UIControl.Event.editingChanged)
        
        bLabel = UILabel()
        self.view.addSubview(bLabel!)
        bLabel?.text = "B:"
        bLabel?.translatesAutoresizingMaskIntoConstraints = false
        bLabel?.textAlignment = .left
        if #available(iOS 9.0, *) {
            bLabel?.leftAnchor.constraint(equalTo: self.gText!.rightAnchor, constant: 5).isActive = true
            bLabel?.topAnchor.constraint(equalTo: self.hexLabel!.bottomAnchor, constant: 10).isActive = true
            bLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
            bLabel?.widthAnchor.constraint(equalToConstant: 20).isActive = true
        }
        
        bText = UITextField()
        self.view.addSubview(bText!)
        bText?.placeholder = "0-255"
        bText?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            bText?.leftAnchor.constraint(equalTo: self.bLabel!.rightAnchor, constant: 5).isActive = true
            bText?.topAnchor.constraint(equalTo: self.hexLabel!.bottomAnchor, constant: 10).isActive = true
            bText?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            bText?.widthAnchor.constraint(equalToConstant: 60).isActive = true
        }
        bText?.addTarget(self, action: #selector(didChangeRGBTextfield), for: UIControl.Event.editingChanged)
        
        rLabel?.isHidden = true
        rText?.isHidden = true
        gLabel?.isHidden = true
        gText?.isHidden = true
        bLabel?.isHidden = true
        bText?.isHidden = true
        
        alphaLabel = UILabel()
        self.view.addSubview(alphaLabel!)
        alphaLabel?.text = "Alpha:"
        alphaLabel?.translatesAutoresizingMaskIntoConstraints = false
        alphaLabel?.textAlignment = .left
        if #available(iOS 9.0, *) {
            alphaLabel?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
            alphaLabel?.topAnchor.constraint(equalTo: self.colorWell!.bottomAnchor, constant: 15).isActive = true
            alphaLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
            alphaLabel?.widthAnchor.constraint(equalToConstant: 70).isActive = true
        }
        alphaValue = UILabel()
        self.view.addSubview(alphaValue!)
        alphaValue?.text = "0.0"
        alphaValue?.translatesAutoresizingMaskIntoConstraints = false
        alphaValue?.textAlignment = .left
        if #available(iOS 9.0, *) {
        alphaValue?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        alphaValue?.centerYAnchor.constraint(equalTo: self.alphaLabel!.centerYAnchor).isActive = true
        alphaValue?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        alphaValue?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        alphaSlider = UISlider()
        alphaSlider?.minimumValue = 0.0
        alphaSlider?.maximumValue = 1.0
        self.view.addSubview(alphaSlider!)
        alphaSlider?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
        alphaSlider?.leftAnchor.constraint(equalTo: alphaLabel!.rightAnchor, constant: 10).isActive = true
        alphaSlider?.rightAnchor.constraint(equalTo: alphaValue!.leftAnchor, constant: -10).isActive = true
        alphaSlider?.centerYAnchor.constraint(equalTo: self.alphaLabel!.centerYAnchor).isActive = true
        alphaSlider?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        alphaSlider?.addTarget(self, action: #selector(didChangeSlider), for: UIControl.Event.valueChanged)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.scrollDirection = .horizontal
        previousCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        previousCollectionView?.delegate = self
        previousCollectionView?.dataSource = self
        previousCollectionView?.backgroundColor = .clear
        previousCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(previousCollectionView!)
        previousCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            previousCollectionView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
            previousCollectionView?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
            previousCollectionView?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
            previousCollectionView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        previousCollectionView?.reloadData()
        
        huePicker = HuePicker(frame: CGRect(x: 0, y: 300, width: 100, height: 100))
        self.view.addSubview(huePicker!)
        huePicker?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            huePicker?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -120).isActive = true
            huePicker?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
            huePicker?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
            huePicker?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        colorPicker = ColorPicker(frame: CGRect(x: 0, y: 200, width: 100, height: 100))
        self.view.addSubview(colorPicker!)
        colorPicker?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            colorPicker?.topAnchor.constraint(equalTo: alphaLabel!.bottomAnchor, constant: 20).isActive = true
            colorPicker?.bottomAnchor.constraint(equalTo: huePicker!.topAnchor, constant: -30).isActive = true
            colorPicker?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
            colorPicker?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
            colorPicker?.heightAnchor.constraint(equalToConstant: 400).isActive = true
        }
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
    
    @objc func didChangeTextfield(){
        if let colorStr = self.hexText?.text, colorStr.count == 7 {
            var color = UIColor(fromHexString: colorStr)
            color = color.withAlphaComponent(CGFloat(getAlphaValue()))
            self.applyColor(color)
        }
    }
    
    @objc func didChangeRGBTextfield(){
        
    }
    @objc func didChangeSlider(){
        self.alphaValue?.text = String(describing:getAlphaValue())
    }
    
    func getAlphaValue()->Float{
        if let float = self.alphaSlider?.value {
            return roundf(float*Float(10))/Float(10)
        }
        return 0
    }
    
    
    @objc func close(){
        if var color = pickerController?.color {
            color = color.withAlphaComponent(CGFloat(getAlphaValue()))
            let colourHex = color.toHexString()
            var ary = UIDesign.colours.filter { (val) -> Bool in
                return val != colourHex
            }
            ary.insert(color.toHexString(), at: 0)
            UIDesign.colours = ary
            self.delegate?.update(color: color)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func applyColor(_ color:UIColor){
        selectedColor = color
        self.alphaSlider?.value = Float(color.cgColor.alpha)
        self.alphaValue?.text = String(describing:getAlphaValue())
        self.hexText?.text = color.toShortHexString()
        self.pickerController?.color = color
    }
    
}

extension DesignColorViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let colour = UIColor(fromHexString: colours[indexPath.row])
        applyColor(colour)
    }
}

extension DesignColorViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = CGFloat(1.0)
        let colour = UIColor(fromHexString: colours[indexPath.row])
        cell.backgroundColor = colour
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colours.count
    }
}
