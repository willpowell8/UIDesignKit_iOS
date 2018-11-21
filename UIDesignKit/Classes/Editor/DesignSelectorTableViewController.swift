//
//  DesignSelectorTableViewController.swift
//  UIDesignKit
//
//  Created by Will Powell on 21/11/2018.
//

import UIKit

protocol DesignSelectorTableViewControllerDelegate{
    func designSelectedValue(_ field:String?, _ int:Int)
}


class DesignSelectorTableViewController: UITableViewController {
    
    var values:[(label:String, value:Int)]?
    var currentlySelected:Int?
    var delegate:DesignSelectorTableViewControllerDelegate?
    var field:String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return values?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "OptionCell")
        if let v = values {
            let value = v[indexPath.row]
            cell.textLabel?.text = value.label
            if let currentValue = currentlySelected, currentValue ==  value.value {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let v = values {
            let value = v[indexPath.row]
            self.navigationController?.popViewController(animated: true)
            delegate?.designSelectedValue(field, value.value)
        }
    }

}
