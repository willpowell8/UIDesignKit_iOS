//
//  ViewController.swift
//  UIDesignKit
//
//  Created by Will Powell on 11/22/2016.
//  Copyright (c) 2016 Will Powell. All rights reserved.
//

import UIKit
import UIDesignKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let color = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        color.ThemeKey = "WarningColor"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

