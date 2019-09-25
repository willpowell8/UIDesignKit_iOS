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
    @IBOutlet var tableView:UITableView?
    var selectedCell:DesignViewCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true // available in IOS13
        }
        view.backgroundColor = .white
        if #available(iOS 13.0, *) {
            self.view.gestureRecognizers?[0].isEnabled = false
            self.navigationController?.isModalInPresentation = false
        }
        tableView?.dataSource = self
        tableView?.delegate = self
        /*view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        }*/
    }
    
    func addDesignViewButton(){
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        navigationItem.leftBarButtonItems = [cancelButton]
        
        let openAll = UIBarButtonItem(title: "All Keys", style: .plain, target: self, action: #selector(closeAndOpenAll))
        navigationItem.rightBarButtonItems = [openAll]
    }
    
    @objc func close(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeAndOpenAll(){
        dismiss(animated: false) {
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
        var keys = designProperties?.compactMap({ (key,_) -> String? in
            return key
        })
        keys = keys?.sorted(by: { (k1, k2) -> Bool in
            return k1 < k2
        })
        
        keys?.forEach({ (key) in
            strings.append(key)
            let value = designProperties?[key]
            var cell = DesignViewCell()
            if let details = value as? [String:Any] {
                if let type = details["type"] as? String {
                    switch(type){
                        case "INT":
                            if key == "textAlignment" {
                                let s = SelectorDesignViewCell(style: .value1, reuseIdentifier: "TextAlignmentCell")
                                s.possibleValues = UIDesign.textAlignmentOptions
                                cell = s
                            }else if key == "contentMode"{
                                let s = SelectorDesignViewCell(style: .value1, reuseIdentifier: "ContentModeCell")
                                s.possibleValues = UIDesign.imageContentModeOptions
                                cell = s
                            }else{
                                cell = IntDesignViewCell()
                            }
                        case "FLOAT": cell = FloatDesignViewCell()
                        case "COLOR": cell = ColorDesignViewCell()
                        case "FONT": cell = FontDesignViewCell(style: .value1, reuseIdentifier: "FontCell")
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
        tableView?.reloadData()
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
            }else if let fontCell = cell as? FontDesignViewCell {
                let fontSelector = FontSelectorViewController()
                fontSelector.designFont = fontCell.cellFont
                fontSelector.property = fontCell.property
                fontSelector.delegate = self
                navigationController?.pushViewController(fontSelector, animated: true)
            }else if let selectorCell = cell as? SelectorDesignViewCell {
                let selectorViewController = DesignSelectorTableViewController()
                selectorViewController.values = selectorCell.possibleValues
                selectorViewController.currentlySelected = selectorCell.value
                selectorViewController.field = selectorCell.property
                selectorViewController.delegate = self
                navigationController?.pushViewController(selectorViewController, animated: true)
            }
        }
    }
}

extension DesignViewController: FontSelectorViewControllerDelegate {
    func selectedFont(font: UIFont, property:String?) {
        if let fontCell = selectedCell as? FontDesignViewCell {
            fontCell.applyFont(font: font)
            if let property = property {
                self.updateValue(property: property, value: font.toDesignString())
            }
        }
    }
}

extension DesignViewController:DesignSelectorTableViewControllerDelegate{
    func designSelectedValue(_ field: String?, _ int: Int) {
        if let property = field {
            self.updateValue(property: property, value: int)
        }
        if let cell = selectedCell as? SelectorDesignViewCell {
            cell.value = int
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
