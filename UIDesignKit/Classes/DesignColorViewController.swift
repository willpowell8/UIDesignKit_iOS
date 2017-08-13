//
//  DesignColorViewController.swift
//  Pods
//
//  Created by Will Powell on 13/08/2017.
//
//

import UIKit

protocol DesignColorViewControllerDelegate{
    func update(color:UIColor)
}

class DesignColorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
