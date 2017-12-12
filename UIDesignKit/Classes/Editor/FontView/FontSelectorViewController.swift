//
//  FontSelectorViewController.swift
//  UIDesignKit
//
//  Created by Will Powell on 20/10/2017.
//

import UIKit

class FontSelectorViewController: UIViewController {
    
    let tableView = UITableView()
    var designCells:[UITableViewCell]?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Font Selector"
        designCells = [UITableViewCell]()
        let sizeCell = IntDesignViewCell()
        designCells?.append(sizeCell)
        sizeCell.property = "size"
        sizeCell.setup()
        
        let typeCell = UITableViewCell(style: .value1, reuseIdentifier: "Type Cell")
        typeCell.textLabel?.text = "Font"
        typeCell.detailTextLabel?.text = "SF"
        typeCell.accessoryType = .disclosureIndicator
        designCells?.append(typeCell)
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
}

extension FontSelectorViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        printFonts()
        if let cell = self.designCells?[indexPath.row] as? DesignViewCell {
            /*selectedCell = cell
            if let colorCell = cell as? ColorDesignViewCell {
                let colorVC = DesignColorViewController()
                colorVC.delegate = self
                colorVC.applyColor(colorCell.color)
                colorVC.property = colorCell.property
                navigationController?.pushViewController(colorVC, animated: true)
            }else if cell is FontDesignViewCell {
                let fontSelector = FontSelectorViewController()
                navigationController?.pushViewController(fontSelector, animated: true)
            }*/
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
