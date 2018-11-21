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
    
    
    @IBOutlet var appNameLabel:UILabel?
    @IBOutlet var appUuidLabel:UILabel?
    @IBOutlet var statusLabel:UILabel?
    @IBOutlet var statusView:UIView?

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
        updateStatus()
    }
    
    func updateStatus(){
        appNameLabel?.text = UIDesign.appName ?? "Unknown"
        appUuidLabel?.text = UIDesign.appKey ?? "Unknown"
        switch(UIDesign.status){
        case .unknown:
            statusLabel?.text = "unknown"
            statusView?.backgroundColor = UIColor.lightGray
            break
        case .connected:
            statusLabel?.text = "connected"
            statusView?.backgroundColor = UIColor.green
            break
        case .connecting:
            statusLabel?.text = "connecting"
            statusView?.backgroundColor = UIColor.orange
            break
        case .disconnected:
            statusLabel?.text = "disconnected"
            statusView?.backgroundColor = UIColor.red
            break
        case .notConnected:
            statusLabel?.text = "not connected"
            statusView?.backgroundColor = UIColor.black
            break
        case .starting:
            statusLabel?.text = "starting"
            statusView?.backgroundColor = UIColor.orange
            break
        }
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
            let podBundle = Bundle(for: DesignInlineEditorHandler.self)
            let bundleURL = podBundle.url(forResource: "UIDesignKit", withExtension: "bundle")
            let bundle = Bundle(url: bundleURL!)!
            guard let vc = UIStoryboard(name: "Storyboard", bundle: bundle).instantiateViewController(withIdentifier: "DesignViewController") as? DesignViewController else {
                return
            }
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
