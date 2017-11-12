//
//  AllDesignKeysTableViewController.swift
//  UIDesignKit
//
//  Created by Will Powell on 12/11/2017.
//

import UIKit

class AllDesignKeysTableViewController: UITableViewController {
    
    var values = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "UIDesignKit Keys"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItems = [cancelButton]
        var values = [String]()
        UIDesign.loadedDesign.forEach { (arg) in
            let (key, _) = arg
            if let k = key as? String {
                values.append(k)
            }
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "KEYCELL")
        self.values = values
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return values.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KEYCELL", for: indexPath)

        let value = values[indexPath.row]
        cell.textLabel?.text = value

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = values[indexPath.row]
        if let elementData = UIDesign.get(value), let data = elementData["data"] as?[String:Any] {
            var formatterData = [String:Any]()
            data.forEach({ (arg) in
                let (key, value) = arg
                if var dataV = value as? [String:Any] {
                    dataV["value"] = dataV["universal"]
                    formatterData[key] = dataV
                }
            })
            let vc = DesignViewController()
            vc.designKey = value
            vc.designProperties = formatterData
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
