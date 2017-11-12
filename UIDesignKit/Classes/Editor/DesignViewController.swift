//
//  DesignViewController.swift
//  Pods
//
//  Created by Will Powell on 08/08/2017.
//
//
import Foundation

class DesignViewController:UIViewController{
    
    var targetView:UIView? {
        didSet{
            self.processView()
        }
    }
    
    var designProperties:[String:Any]? {
        didSet{
            applyDesignProperties()
        }
    }
    var designStrings:[String]?
    var designKey:String?
    var designCells:[UITableViewCell]?
    var tableView = UITableView()
    var selectedCell:DesignViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        }
    }
    
    func addDesignViewButton(){
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        navigationItem.leftBarButtonItems = [cancelButton]
        
        let openAll = UIBarButtonItem(title: "All Keys", style: .plain, target: self, action: #selector(closeAndOpenAll))
        navigationItem.rightBarButtonItems = [openAll]
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func closeAndOpenAll(){
        self.dismiss(animated: true) {
            UIDesign.showAllDesignKeysView()
        }
    }
    
    private func processView(){
        guard let target = targetView else {
            return
        }
        addDesignViewButton()
        designKey = target.DesignKey
        designProperties = target.getDesignProperties(data: [String:Any]())
    }
    
    func applyDesignProperties(){
        var strings = [String]()
        var cells = [DesignViewCell]()
        designProperties?.forEach({ (key,value) in
            strings.append(key)
            var cell = DesignViewCell()
            if let details = value as? [String:Any] {
                if let type = details["type"] as? String {
                    switch(type){
                        case "INT": cell = IntDesignViewCell()
                        case "FLOAT": cell = FloatDesignViewCell()
                        case "COLOR": cell = ColorDesignViewCell()
                        case "FONT": cell = FontDesignViewCell()
                        case "BOOL": cell = BoolDesignViewCell()
                        default: cell = TextDesignViewCell()
                    }
                }
            }
            cell.delegate = self
            cell.property = key
            cell.details = value as? [String:Any]
            cells.append(cell)
        })
        designStrings = strings
        
        designCells = cells
        navigationItem.title = designKey
        tableView.reloadData()
    }
}

extension DesignViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.designCells?[indexPath.row] as? DesignViewCell {
            selectedCell = cell
            if let colorCell = cell as? ColorDesignViewCell {
                let colorVC = DesignColorViewController()
                colorVC.delegate = self
                colorVC.applyColor(colorCell.color)
                colorVC.property = colorCell.property
                navigationController?.pushViewController(colorVC, animated: true)
            }else if cell is FontDesignViewCell {
                let fontSelector = FontSelectorViewController()
                navigationController?.pushViewController(fontSelector, animated: true)
            }
        }
    }
}

extension DesignViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return designCells?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        return designCells?[indexPath.row] ?? UITableViewCell()
    }
}

extension DesignViewController:DesignViewCellDelegate{
    func updateValue(property: String, value: Any) {
        guard let designKey = self.designKey else{
            return
        }
        UIDesign.updateKeyProperty(designKey, property: property, value: value)
    }
}

extension DesignViewController:DesignColorViewControllerDelegate{
    func update(color: UIColor) {
        if let cell = selectedCell as? ColorDesignViewCell {
            cell.applyColor(color)
        }
    }
}
