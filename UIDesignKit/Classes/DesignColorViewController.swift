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
    //private let COLOR_PICKER_VIEW_HEIGHT = CGFloat(290)
    
    private var mainColorPickerView : UIView!
    private var secondaryColorPickerView : UIView!
    private var mainColorSelectorImage : UIImageView!
    private var secondaryColorSelectorImage : UIImageView!
    private var selectedColor : UIColor!
    
    //MARK: contructor
    
    init(){
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.gray
        self.createSecondaryPickerview()
        self.createMainColorPickerView()
        self.createMainColorSelector()
        self.createSecondaryColorSelector()
        selectedColor = self.colorOfPoint(point: self.mainColorSelectorImage.center,
                                          inView: self.mainColorPickerView)
        updateSecondaryPickerView(color: selectedColor)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItems = [doneButton]
        
    }
    
    func done(){
        self.delegate?.update(color: self.selectedColor)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return .portrait
    }
    
    private func getBundle()-> Bundle{
        let podBundle =  Bundle.init(for: DesignColorViewController.self)
        let bundleURL = podBundle.url(forResource: "UIDesignKit" , withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    private func createMainColorPickerView(){
        let WIDTH = CGFloat(44.00)
        let HEIGHT = self.secondaryColorPickerView.frame.size.width
        let size = CGSize.init(width: WIDTH, height: HEIGHT)
        let origin = CGPoint.init(x: (self.view.frame.size.width - WIDTH) - 15,
                                  y: (self.view.frame.size.height - HEIGHT) - 15)
        self.mainColorPickerView = UIView.init(frame: CGRect.init(origin: origin, size: size))
        
        let allGradientColor = [UIColor.red.cgColor,
                                UIColor.yellow.cgColor,
                                UIColor.green.cgColor,
                                UIColor.cyan.cgColor,
                                UIColor.blue.cgColor,
                                UIColor.magenta.cgColor,
                                UIColor.red.cgColor];
        let allColorGradient = gradientLayer(inView:self.mainColorPickerView,
                                             withColor: allGradientColor,
                                             orientation: .horizontal)
        
        self.mainColorPickerView.layer.addSublayer(allColorGradient)
        self.mainColorPickerView.layer.borderColor = UIColor.black.cgColor
        self.mainColorPickerView.layer.borderWidth = 1.0
        
        let tapGesture = UITapGestureRecognizer.init(target: self,
                                                     action: #selector(self.mainPickerDidTap(sender:)))
        tapGesture.numberOfTapsRequired = 1
        let panGesture = UIPanGestureRecognizer.init(target: self,
                                                     action: #selector(self.mainPickerDidTap(sender:)))
        
        self.mainColorPickerView.addGestureRecognizer(tapGesture)
        self.mainColorPickerView.addGestureRecognizer(panGesture)
        
        self.view.addSubview(self.mainColorPickerView)
    }
    
    private func createSecondaryPickerview(){
        let WIDTH = self.deviceFrame().width - 89
        let HEIGHT = WIDTH
        //        let WIDTH = COLOR_PICKER_VIEW_HEIGHT
        //        let HEIGHT = COLOR_PICKER_VIEW_HEIGHT
        let size = CGSize.init(width: WIDTH, height: HEIGHT)
        let origin = CGPoint.init(x: 15,
                                  y: (self.view.frame.size.height - WIDTH) - 15)
        self.secondaryColorPickerView = UIView.init(frame: CGRect.init(origin: origin, size: size))
        
        let darkColor = [UIColor.black.cgColor,
                         UIColor.red.cgColor]
        let firstLayer = self.gradientLayer(inView: self.secondaryColorPickerView,
                                            withColor: darkColor, orientation: .vertical)
        let lightColor = [UIColor.clear.cgColor,
                          UIColor.white.cgColor]
        let secondLayer = self.gradientLayer(inView: self.secondaryColorPickerView,
                                             withColor: lightColor, orientation: .horizontal)
        self.secondaryColorPickerView.layer.addSublayer(firstLayer)
        self.secondaryColorPickerView.layer.addSublayer(secondLayer)
        self.secondaryColorPickerView.layer.borderColor = UIColor.black.cgColor
        self.secondaryColorPickerView.layer.borderWidth = 1.0
        
        let tapGesture = UITapGestureRecognizer.init(target: self,
                                                     action: #selector(secondaryPickerDidTap(sender:)))
        tapGesture.numberOfTapsRequired = 1
        let panGesture = UIPanGestureRecognizer.init(target: self,
                                                     action: #selector(secondaryPickerDidTap(sender:)))
        self.secondaryColorPickerView.addGestureRecognizer(tapGesture)
        self.secondaryColorPickerView.addGestureRecognizer(panGesture)
        
        self.view.addSubview(self.secondaryColorPickerView)
    }
    
    private func createMainColorSelector(){
        let selector = UIImage(named: "selector_rectangle", in: getBundle(), compatibleWith: nil)
        self.mainColorSelectorImage = UIImageView.init(image: selector)
        self.mainColorSelectorImage.frame = CGRect.init(x: -5,
                                                        y: 0,
                                                        width: 54.0,
                                                        height: 10)
        self.mainColorPickerView.insertSubview(self.mainColorSelectorImage, at: 1)
    }
    
    private func createSecondaryColorSelector(){
        let selector = UIImage(named: "selector_round", in: getBundle(), compatibleWith: nil)
        self.secondaryColorSelectorImage = UIImageView.init(image: selector)
        self.secondaryColorSelectorImage.frame = CGRect.init(x: 0,
                                                             y: 0,
                                                             width: 20,
                                                             height: 20)
        self.secondaryColorSelectorImage.center.x = self.secondaryColorPickerView.frame.size.height - 2
        self.secondaryColorPickerView.insertSubview(self.secondaryColorSelectorImage, at: 2)
    }
    
    // MARK: gesture recognizer
    
    @objc private func mainPickerDidTap(sender: UIGestureRecognizer){
        let panLocation = sender.location(in: self.mainColorPickerView)
        
        if (self.mainColorPickerView.bounds.origin.y + 3)...(self.mainColorPickerView.bounds.origin.y + self.mainColorPickerView.bounds.size.height - 3) ~= panLocation.y{
            self.mainColorSelectorImage.center.y = panLocation.y
            let selectedColor = self.colorOfPoint(point: self.mainColorSelectorImage.center,
                                                  inView: self.mainColorPickerView)
            self.updateSecondaryPickerView(color: selectedColor)
        }
    }
    
    @objc private func secondaryPickerDidTap(sender: UIGestureRecognizer){
        let MARGIN = CGFloat(3)
        let panLocation = sender.location(in: self.secondaryColorPickerView)
        
        if MARGIN ... (self.secondaryColorPickerView.frame.size.width - MARGIN) ~= panLocation.x{
            self.secondaryColorSelectorImage.center.x = panLocation.x
        }
        
        if MARGIN ... (self.secondaryColorPickerView.frame.size.height - MARGIN) ~= panLocation.y{
            self.secondaryColorSelectorImage.center.y = panLocation.y
        }
        
        self.updateBackgroundColor()
        
    }
    
    // MARK: backend logic
    
    private func updateSecondaryPickerView(color:UIColor){
        let darkColor = [UIColor.black.cgColor,
                         color.cgColor]
        let firstLayer = self.gradientLayer(inView: self.secondaryColorPickerView,
                                            withColor: darkColor, orientation: .vertical)
        self.secondaryColorPickerView.layer.sublayers?.removeFirst()
        self.secondaryColorPickerView.layer.insertSublayer(firstLayer, at: 0)
        self.updateBackgroundColor()
    }
    
    private func updateBackgroundColor(){
        self.selectedColor = self.colorOfPoint(point: self.secondaryColorSelectorImage.center,
                                               inView: self.secondaryColorPickerView);
        self.view.backgroundColor = self.selectedColor
        var rgbString = self.colorToRGB(self.selectedColor)
        rgbString += "\n" + self.colorToHex(self.selectedColor)
        
        updateColor()
    }
    
    //update color when background color too dark to see
    private func updateColor(){
        if self.secondaryColorSelectorImage.center.x < self.secondaryColorPickerView.frame.size.width / 2 && self.secondaryColorSelectorImage.center.y < self.secondaryColorPickerView.frame.size.height / 2{
            
            self.secondaryColorPickerView.layer.borderColor = UIColor.white.cgColor
            self.mainColorPickerView.layer.borderColor = UIColor.white.cgColor
            let pickerImage = UIImage(named: "selector_rectangle_white", in: getBundle(), compatibleWith: nil)
            self.mainColorSelectorImage.image = pickerImage
            
            UIApplication.shared.statusBarStyle = .lightContent
        }
        else{
            self.secondaryColorPickerView.layer.borderColor = UIColor.black.cgColor
            self.mainColorPickerView.layer.borderColor = UIColor.black.cgColor
            let pickerImage = UIImage(named: "selector_rectangle", in: getBundle(), compatibleWith: nil)
            self.mainColorSelectorImage.image = pickerImage
            
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    private func gradientLayer(inView:UIView, withColor:[CGColor],orientation:GRADIENT) -> CALayer{
        let gradient = CAGradientLayer.init()
        gradient.frame = CGRect.init(x: 0,
                                     y: 0,
                                     width: inView.frame.size.width,
                                     height: inView.frame.size.height)
        gradient.colors = withColor
        if orientation == .vertical{
            gradient.startPoint = CGPoint.init(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint.init(x: 1.0, y: 0.5)
        }
        else{
            gradient.startPoint = CGPoint.init(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint.init(x: 0.0, y: 1.0)
        }
        return gradient
    }
    
    private func colorOfPoint(point: CGPoint, inView:UIView) -> UIColor{
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        inView.layer.render(in: context!)
        
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deallocate(capacity: 4)
        return color
    }
    
    //return current device frame
    private func deviceFrame() -> CGSize{
        let deviceWidth = UIScreen.main.bounds.size.width
        let deviceHeight = UIScreen.main.bounds.size.height
        let deviceScreenSize = CGSize.init(width: deviceWidth, height: deviceHeight)
        return deviceScreenSize;
    }
    
    private func colorToRGB(_ color: UIColor) -> String{
        let redValue = (color.cgColor.components?[0])! * 255
        let greenValue = (color.cgColor.components?[1])! * 255
        let blueValue = (color.cgColor.components?[2])! * 255
        let rgbString = String.init(format: "rgb(%.0f,%.0f,%.0f)", redValue, greenValue, blueValue)
        return rgbString
    }
    
    private func colorToHex(_ color: UIColor) -> String{
        let red = color.cgColor.components?[0]
        let green = color.cgColor.components?[1]
        let blue = color.cgColor.components?[2]
        
        let hexString = String(format: "#%02lX%02lX%02lX",
                               lroundf(Float(red! * 255)),
                               lroundf(Float(green! * 255)),
                               lroundf(Float(blue! * 255)))
        return hexString
    }
}
