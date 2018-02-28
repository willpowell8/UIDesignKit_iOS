//
//  FontSelectorViewController.swift
//  UIDesignKit
//
//  Created by Will Powell on 20/10/2017.
//

import UIKit

protocol FontListDelegate {
    func selectFont(family:String, fontName:String)
}

class FontList:UITableViewController {
    
    var selectedFontFamily:String?
    var selectedFont:String?
    var delegate:FontListDelegate?
    
    var fonts = [(name:String, children:[String])]()
    func getFonts(){
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
            fonts.append((name: familyName, children: names))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFonts()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fonts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fonts[section].children.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let family = fonts[indexPath.section]
        let font = family.children[indexPath.row]
        let fontValue = UIFont(name: font, size: 14.0)
        cell.textLabel?.text = font
        cell.textLabel?.font = fontValue
        cell.accessoryType = selectedFont == font ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let family = fonts[indexPath.section]
        let font = family.children[indexPath.row]
        self.selectedFont = font
        self.selectedFontFamily = family.name
        delegate?.selectFont(family: family.name, fontName: font)
        self.navigationController?.popViewController(animated: true)
    }
}

protocol FontSelectorViewControllerDelegate {
    func selectedFont(font:UIFont, property:String?)
}

class FontSelectorViewController: UIViewController, FontListDelegate {
    
    let tableView = UITableView()
    var designCells:[UITableViewCell]?
    var designFont:UIFont?
    var property:String?
    var selectedCell:DesignViewCell?
    var delegate:FontSelectorViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Font Selector"
        designCells = [UITableViewCell]()
        let sizeCell = IntDesignViewCell()
        designCells?.append(sizeCell)
        sizeCell.property = "Size"
        let fontSize = designFont?.pointSize ?? 9.0
        sizeCell.details = ["value":fontSize]
        sizeCell.delegate = self
        sizeCell.setup()
        
        let fontFamilyCell = FontFamilyDesignViewCell(style: .value1, reuseIdentifier: "Family Cell")
        fontFamilyCell.textLabel?.text = "Font Family"
        fontFamilyCell.detailTextLabel?.text = designFont?.familyName
        fontFamilyCell.accessoryType = .disclosureIndicator
        designCells?.append(fontFamilyCell)
        
        let fontCell = FontFamilyDesignViewCell(style: .value1, reuseIdentifier: "Type Cell")
        fontCell.textLabel?.text = "Font"
        fontCell.detailTextLabel?.text = designFont?.fontName
        fontCell.accessoryType = .disclosureIndicator
        designCells?.append(fontCell)
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        }
        tableView.reloadData()
        
        // Do any additional setup after loading the view.
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClick))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doneClick(){
        if let font = self.designFont {
            delegate?.selectedFont(font: font, property:self.property)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func printFonts() {
        
    }
    
    func selectFont(family:String, fontName:String){
        let size = designFont?.pointSize ?? 9.0
        let font = UIFont(name: fontName, size: size)
        self.designFont = font
        if let fontFamilyCell = designCells?[1] as? FontFamilyDesignViewCell {
            fontFamilyCell.detailTextLabel?.text = designFont?.familyName
        }
        if let fontCell = designCells?[2] as? FontFamilyDesignViewCell {
            fontCell.detailTextLabel?.text = designFont?.fontName
        }
    }
}

extension FontSelectorViewController : DesignViewCellDelegate {
    func updateValue(property:String, value:Any) {
        if let floatValue = value as? Float, let designFontName = self.designFont?.fontName {
            let cgfloat = CGFloat(floatValue)
            let font = UIFont(name: designFontName, size: cgfloat)
            self.designFont = font
        }
    }
}

extension FontSelectorViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = self.designCells?[indexPath.row] as? DesignViewCell {
            
            selectedCell = cell
            if cell is FontFamilyDesignViewCell {
                let fontList = FontList()
                fontList.delegate = self
                navigationController?.pushViewController(fontList, animated: true)
            }
        }
    }
}

extension FontSelectorViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return designCells?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        return designCells?[indexPath.row] ?? UITableViewCell()
    }
}
