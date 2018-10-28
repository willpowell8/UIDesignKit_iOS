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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var selectedFontFamily:String?
    var selectedFont:String?
    var delegate:FontListDelegate?
    
    var fonts = [(name:String, children:[String])]() {
        didSet{
            filteredFonts = fonts
        }
    }
    var filteredFonts = [(name:String, children:[String])]()
    func getFonts(){
        let fontFamilyNames = UIFont.familyNames
        var newFonts = [(name:String, children:[String])]()
        for familyName in fontFamilyNames {
            var names = UIFont.fontNames(forFamilyName: familyName)
            names = names.sorted(by: { (name1, name2) -> Bool in
                return name1 > name2
            })
            newFonts.append((name: familyName, children: names))
        }
        fonts = newFonts.sorted { (n1, n2) -> Bool in
            return n1.name < n2.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = "Search Fonts"
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
        getFonts()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filteredFonts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFonts[section].children.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredFonts[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let family = filteredFonts[indexPath.section]
        let font = family.children[indexPath.row]
        let fontValue = UIFont(name: font, size: 14.0)
        cell.textLabel?.text = font
        cell.textLabel?.font = fontValue
        cell.accessoryType = selectedFont == font ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let family = filteredFonts[indexPath.section]
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
    var designFont:UIFont? {
        didSet{
            if Thread.isMainThread {
                demoFontLabel.font = designFont
            }else{
                DispatchQueue.main.async {
                    self.demoFontLabel.font = self.designFont
                }
            }
        }
    }
    var property:String?
    var selectedCell:DesignViewCell?
    var delegate:FontSelectorViewControllerDelegate?
    var demoFontLabel = UILabel()
    var recentFonts = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        UserDefaults.standard.array(forKey: "UIDesignKit_fonts")
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
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 200))
        view.addSubview(label)
        if #available(iOS 9.0, *) {
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            label.heightAnchor.constraint(equalToConstant: 200).isActive = true
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        }
        label.text = "Example Font"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = self.designFont
        demoFontLabel = label
        
        // Do any additional setup after loading the view.
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClick))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func doneClick(){
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

extension FontList: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard var term = searchController.searchBar.text, term != "" else {
            filteredFonts = fonts
            tableView.reloadData()
            return
        }
        term = term.lowercased()
        filteredFonts = fonts.compactMap({ (name,children) -> (name:String, children:[String])? in
            if name.lowercased().contains(term) {
                return (name:name, children:children)
            }
            return nil
        })
        tableView.reloadData()
    }
}
