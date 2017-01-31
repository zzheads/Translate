//
//  ViewController.swift
//  Translate
//
//  Created by Alexey Papin on 31.01.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for code in HTTPStatusCode.allValues {
            print("Code: \(code), message: \(code.fullMessage)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

