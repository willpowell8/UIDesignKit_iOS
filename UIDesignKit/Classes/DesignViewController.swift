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
    
    var designProperties:[String:Any]?
    var designStrings:[String]?
    var designKey:String?
    var designCells:[UITableViewCell]?
    var tableView:UITableView?
    var selectedCell:DesignViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItems = [cancelButton]
        processView()
        tableView = UITableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        //tableView?.allowsSelection = false
        self.view.addSubview(tableView!)
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
        tableView?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        tableView?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        tableView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        tableView?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        }
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func processView(){
        guard let target = targetView else {
            return
        }
        self.designProperties = target.getDesignProperties(data: [String:Any]())
        var strings = [String]()
        var cells = [DesignViewCell]()
        self.designProperties?.forEach({ (key,value) in
            strings.append(key)
            var cell = DesignViewCell()
            if let details = value as? [String:Any] {
                if let type = details["type"] as? String {
                    switch(type){
                        case "INT": cell = IntDesignViewCell()
                        case "FLOAT": cell = FloatDesignViewCell()
                        case "COLOR": cell = ColorDesignViewCell()
                        case "FONT": cell = FontDesignViewCell()
                        default: cell = TextDesignViewCell()
                    }
                }
            }
            cell.delegate = self
            cell.property = key
            cell.details = value as? [String:Any]
            cells.append(cell)
        })
        self.designStrings = strings
        self.designKey = target.DesignKey
        self.designCells = cells
        self.navigationItem.title = self.designKey
        self.tableView?.reloadData()
    }
}

extension DesignViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.designCells?[indexPath.row] as? DesignViewCell {
            self.selectedCell = cell
            if let colorCell = cell as? ColorDesignViewCell {
                let colorVC = DesignColorViewController()
                colorVC.delegate = self
                colorVC.applyColor(colorCell.color)
                colorVC.property = colorCell.property
                self.navigationController?.pushViewController(colorVC, animated: true)
            }
        }
    }
}

extension DesignViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let cells = self.designCells {
            return cells.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell = self.designCells?[indexPath.row] {
            return cell
        }
        return UITableViewCell()
    }
}

extension DesignViewController:DesignViewCellDelegate{
    func updateValue(property: String, value: Any) {
        UIDesign.updateKeyProperty(self.designKey!, property: property, value: value)
    }
}

extension DesignViewController:DesignColorViewControllerDelegate{
    func update(color: UIColor) {
        if let cell = self.selectedCell as? ColorDesignViewCell {
            cell.applyColor(color)
        }
    }
}
