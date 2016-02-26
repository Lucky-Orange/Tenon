//
//  ViewController.swift
//  TenonExample
//
//  Created by leqicheng on 15/8/10.
//  Copyright © 2015年 乐其橙. All rights reserved.
//

import UIKit
import Tenon

class ViewController: TenonViewController {

    override func viewDidLoad() {
        self.startPage = "http://image.baidu.com/search/wiseindex?tn=wiseindex"
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

