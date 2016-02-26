//
//  MenuView.swift
//  Tenon
//
//  Created by leqicheng on 15/9/21.
//  Copyright © 2015年 乐其橙. All rights reserved.
//

import UIKit

class MenuView: UIView {
    
    weak var tenonViewController: TenonViewController!

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func exitButtonBeTapped(sender: AnyObject) {
        self.tenonViewController.dismissViewControllerAnimated(true, completion: nil)
    }

}
