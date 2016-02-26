//
//  TenonViewController.swift
//  Tenon
//
//  Created by leqicheng on 15/8/7.
//  Copyright © 2015年 乐其橙. All rights reserved.
//

import UIKit
import Pitaya

extension UIImage {
    
    @available(iOS 7.0, *)
    public class func imageInTenonBundle(name: String, type: String = "png") -> UIImage? {
        let bundle = NSBundle(forClass: TenonViewController.self)
        if let path = bundle.pathForResource("images/\(name)@\(Int(UIScreen.mainScreen().scale).description)x", ofType: type), image = UIImage(contentsOfFile: path) {
            return image
        }
        return nil
    }
}

extension String{
    var md5: String! {
        if let data = dataUsingEncoding(NSUTF8StringEncoding) {
            let MD5Calculator = MD5(data)
            let MD5Data = MD5Calculator.calculate()
            let resultBytes = UnsafeMutablePointer<CUnsignedChar>(MD5Data.bytes)
            let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: MD5Data.length)
            var MD5String = ""
            for c in resultEnumerator {
                MD5String += String(format: "%02x", c)
            }
            return MD5String
        } else {
            return self
        }
    }
    var base64: String! {
        let utf8EncodeData: NSData! = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let base64EncodingData = utf8EncodeData.base64EncodedStringWithOptions([])
        return base64EncodingData
    }
}

public class TenonViewController: MyMainViewController {
    
    var ChannelID: Int!
    var GameID: Int!
    var ChannelUserID: String!
    
    public weak var tenonDelegate: TenonDelegate?
    
    var wkUIDelegate: TenonWKUIDelegate?
    public var MagicButton: UIButton!
    public var pg: UIPanGestureRecognizer!

    static var sharedInstance: TenonViewController!
    
    var menuHeng: MenuView! {
        didSet {
            self.menuHeng.tenonViewController = self
        }
    }
    var menuShu: MenuView! {
        didSet {
            self.menuShu.tenonViewController = self
        }
    }
    var magicButtonOut = true {
        didSet {
            self.wkWebView.userInteractionEnabled = self.magicButtonOut
            self.pg.enabled = self.magicButtonOut
            if self.magicButtonOut {
                self.menuHeng.removeFromSuperview()
                self.menuShu.removeFromSuperview()
                self.MagicButton.setImage(UIImage.imageInTenonBundle("菜单-收起"), forState: .Normal)
                self.moveMagicButtonToNearestSide()
            } else {
                let tag = self.MagicButton.tag - 10000
                if tag >= 0 {
                    var x: CGFloat = 0
                    var y: CGFloat = 0
                    var menuX: CGFloat = 0
                    var menuY: CGFloat = 0
                    var menuHengAlpha: CGFloat = 0
                    var menuShuAlpha: CGFloat = 0
                    let width = self.MagicButton.frame.size.width
                    var magicButtonImageName = "菜单-收起"
                    switch tag {
                    case 0:
                        x = width/2 + 5
                        menuHengAlpha = 1
                        menuX = 105
                        magicButtonImageName = "菜单-展开-右"
                    case 1:
                        x = -width/2 - 5
                        menuHengAlpha = 1
                        menuX = -105
                        magicButtonImageName = "菜单-展开-左"
                    case 2:
                        y = width/2 + 5
                        menuShuAlpha = 1
                        menuY = 105
                        magicButtonImageName = "菜单-展开-下"
                    case 3:
                        y = -width/2 - 5
                        menuShuAlpha = 1
                        menuY = -105
                        magicButtonImageName = "菜单-展开-上"
                    default:
                        break
                    }
                    self.MagicButton.setImage(UIImage.imageInTenonBundle(magicButtonImageName), forState: .Normal)
                    
                    self.menuHeng.frame = CGRectMake(0, 0, 210, 49)
                    self.menuHeng.center = CGPointMake(self.MagicButton.center.x + x, self.MagicButton.center.y - 2)
                    self.menuHeng.layer.cornerRadius = 24.5
                    self.menuHeng.alpha = 0
                    self.view.insertSubview(self.menuHeng, belowSubview: self.MagicButton)
                    
                    self.menuShu.frame = CGRectMake(0, 0, 53, 210)
                    self.menuShu.center = CGPointMake(self.MagicButton.center.x, self.MagicButton.center.y + y)
                    self.menuShu.layer.cornerRadius = 26.5
                    self.menuShu.alpha = 0
                    self.view.insertSubview(self.menuShu, belowSubview: self.MagicButton)
                    
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.MagicButton.alpha = 1
                        self.MagicButton.center.x += x
                        self.MagicButton.center.y += y
                        
                        self.menuHeng.alpha = menuHengAlpha
                        self.menuHeng.center.x += menuX
                        self.menuHeng.center.y += menuY
                        
                        self.menuShu.alpha = menuShuAlpha
                        self.menuShu.center.x += menuX
                        self.menuShu.center.y += menuY
                        }, completion: { (success) -> Void in
                            if success {
                                return
                            }
                    })
                }
            }
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        TenonViewController.sharedInstance = self
        
        let image = UIImage.imageInTenonBundle("菜单-收起")
        self.MagicButton = UIButton(frame: CGRectMake(-image!.size.width/2, 50, image!.size.width, image!.size.height))
        self.MagicButton.addTarget(self, action: "magicButtonBeTapped:", forControlEvents: .TouchUpInside)
        self.MagicButton.setImage(image, forState: .Normal)
        self.MagicButton.tag = 10000
        self.MagicButton.alpha = 0.5

        self.pg = UIPanGestureRecognizer(target: self, action: "pan:")
        self.MagicButton.addGestureRecognizer(self.pg)
        
        self.menuHeng = NSBundle(forClass: TenonViewController.self).loadNibNamed("MenuHeng", owner: self, options: nil).first as! MenuView
        self.menuShu = NSBundle(forClass: TenonViewController.self).loadNibNamed("MenuShu", owner: self, options: nil).first as! MenuView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(MagicButton)
        
//        let ls = LoggingStatus()
//        ls.addOneLog("hello", GID: "world", TuID: "tenon")
//        ls.removeOneLog("hello", GID: "world", TuID: "tenon")
        
        Pita.build(HTTPMethod: .GET, url: "http://tenon-x.com/now")
            .responseString { (string, response) -> Void in
                if let s = string, i = Int(s) {
                    TenonPlugin.timeDiffrence = i - Int(NSDate().timeIntervalSince1970)
                    print("时间戳获取成功！\(i)")
                }
        }
        self.ChannelID = 5
        self.GameID = 1
        self.ChannelUserID = "10086"
        let seed = Int(NSDate().timeIntervalSince1970).description
        let token = (seed + "dd268c8aa57600bdd6a583c1a6564efb").md5
        Pita.build(HTTPMethod: .POST, url: "https://tenon-x.com/api/1/channel-login?seed=\(seed)&token=\(token)")
            .addParams(["channel_id": self.ChannelID, "game_id": self.GameID, "open_id": ChannelUserID, "name": "叶良辰", "head_url": "https://lvwenhan.com/content/uploadfile/201410/cdc61414392103.jpg", "sex": "m"])
            .responseJSON { (json, response) -> Void in
                print(response?.statusCode)
                print(json["status"].int)
        }
    }
    
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.magicButtonOut = true
    }
    
    func pan(recongnizer: UIPanGestureRecognizer) {
        if recongnizer == self.pg {
            if recongnizer.state == .Ended {
                self.magicButtonOut = true
                return
            }
            
            let point = recongnizer.translationInView(self.view)
            let center = self.MagicButton.center
            let size = self.MagicButton.frame.size
            var newCenter = CGPointMake(center.x + point.x, center.y + point.y)
            let ScreenSize = UIScreen.mainScreen().bounds
            if (newCenter.x - size.width/2) < 0 {
                newCenter.x = size.width/2
            }
            if (newCenter.x + size.width/2) > ScreenSize.width {
                newCenter.x = ScreenSize.width - size.width/2
            }
            if (newCenter.y - size.height/2) < 0 {
                newCenter.y = size.height/2
            }
            if (newCenter.y + size.height/2) > ScreenSize.height {
                newCenter.y = ScreenSize.height - size.height/2
            }
            self.MagicButton.center = newCenter
            recongnizer.setTranslation(CGPointMake(0, 0), inView: self.view)
        }
    }
    
    func magicButtonBeTapped(sender: AnyObject) {
        if sender as? UIButton == self.MagicButton {
            self.magicButtonOut = !self.magicButtonOut
        }
    }
    
    func moveMagicButtonToNearestSide() {
        let ScreenWidth = UIScreen.mainScreen().applicationFrame.maxX
        let ScreenHeight = UIScreen.mainScreen().applicationFrame.maxY
        
        let left = self.MagicButton.center.x
        let right = ScreenWidth - left
        let top = self.MagicButton.center.y
        let bottom = ScreenHeight - top
        
        var array = [left, right, top, bottom]
        array = array.sort(<)
        var destinationX: CGFloat = 0
        var destinationY: CGFloat = 0
        var tag = 0
        switch array.first as CGFloat! {
        case left:
            tag = 0
            destinationX = 0
            destinationY = top
        case right:
            tag = 1
            destinationX = ScreenWidth
            destinationY = top
        case top:
            tag = 2
            destinationX = left
            destinationY = 0
        case bottom:
            tag = 3
            destinationX = left
            destinationY = ScreenHeight
        default:
            break
        }
        self.MagicButton.tag = 10000 + tag
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.MagicButton.center = CGPointMake(destinationX, destinationY)
            self.MagicButton.alpha = 0.5
            }) { (success) -> Void in
                if success {
                    return
                }
        }
    }
    
}