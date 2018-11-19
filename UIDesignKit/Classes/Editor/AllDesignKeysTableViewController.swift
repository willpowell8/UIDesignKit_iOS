//
//  AllDesignKeysTableViewController.swift
//  UIDesignKit
//
//  Created by Will Powell on 12/11/2017.
//

import UIKit

class AllDesignKeysTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var values = [String]()
    var originalValues = [String]()
    @IBOutlet var tableView:UITableView?
    @IBOutlet var searchBar:UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "UIDesignKit Keys"
        // Setup the Scope Bar
        //searchController.searchBar.scopeButtonTitles = ["All", "Recent"]
        self.definesPresentationContext = true 
        searchBar?.delegate = self
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItems = [cancelButton]
        var originalValues1 = [String]()
        UIDesign.loadedDesign.forEach { (arg) in
            let (key, _) = arg
            if let k = key as? String {
                originalValues1.append(k)
            }
        }
        originalValues = originalValues1.sorted { (v1, v2) -> Bool in
            return v1 < v2
        }
        values = originalValues
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "KEYCELL")
        tableView?.reloadData()
    }
    
    @objc func close(){
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar?.becomeFirstResponder()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return values.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KEYCELL", for: indexPath)

        let value = values[indexPath.row]
        cell.textLabel?.text = value

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = values[indexPath.row]
        searchBar?.resignFirstResponder()
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

extension AllDesignKeysTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        values = originalValues
        tableView?.reloadData()
        return
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else{
            values = originalValues
            tableView?.reloadData()
            return
        }
        values = originalValues.filter({ (str) -> Bool in
            return str.lowercased().contains(searchTerm.lowercased())
        })
        tableView?.reloadData()
    }
}

extension AllDesignKeysTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
