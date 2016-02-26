//
//  TenonPlugin.swift
//  Tenon
//
//  Created by leqicheng on 15/8/7.
//  Copyright © 2015年 乐其橙. All rights reserved.
//

import Pitaya

@objc(TenonPlugin) class TenonPlugin: CDVPlugin {
    
    static var timeDiffrence = 0

    func evaluateJSFromLocal(command: CDVInvokedUrlCommand) {
        print("success!")
        if let cordovaJSPath = NSBundle(forClass: TenonPlugin.self).pathForResource(command.argumentAtIndex(0).description, ofType: "js", inDirectory: "www" + command.argumentAtIndex(1).description) {
            do {
                let js = try NSString(contentsOfFile: cordovaJSPath, encoding: NSUTF8StringEncoding) as String
                self.webView?.stringByEvaluatingJavaScriptFromString(js)
            } catch {
                NSLog("插件加载失败！\(cordovaJSPath)")
            }
        }
    }
    func getTimestamp(command: CDVInvokedUrlCommand) {
        self.callback(["timestamp": Int(NSDate().timeIntervalSince1970) + TenonPlugin.timeDiffrence], command: command)
    }
    func sendToDesk(command: CDVInvokedUrlCommand) {
        let ChannelUUID = command.argumentAtIndex(0).description
        let GameUUID = command.argumentAtIndex(1).description
        print(ChannelUUID, GameUUID)
    }
    func pay(command: CDVInvokedUrlCommand) {
        TenonViewController.sharedInstance.tenonDelegate?.pay()
        return;
        if let order = command.argumentAtIndex(0) as? Dictionary<String, AnyObject> {
            let params: Dictionary<String, AnyObject> = [
                "developeruuid": "6f144d0c-636a-11e5-9c44-00163e005a2d",
                "gameuuid": "d1d54d60-636a-11e5-bbb2-00163e005a2d",
                "orderid": order["orderid"]!.description,
                "price": order["price"]!.description,
                "name": order["name"]!.description,
                "description": order["description"]!.description,
                "notify_url": order["notify_url"]!.description,
                "timestamp": order["timestamp"]!.description,
                "sign": order["sign"]!.description
                ]
            Pita.build(HTTPMethod: .POST, url: "http://tenon-x.com/api/1/pay/verify")
                .addParams(params)
                .responseJSON ({ (json, response) -> Void in
                    print(json.jsonStringValue)
                })
        } else {
            self.commandDelegate?.sendPluginResult(CDVPluginResult(status: CDVCommandStatus_ERROR), callbackId: command.callbackId)
        }
    }
    
    func callback(dictionary: [String: AnyObject]! = nil, command: CDVInvokedUrlCommand) {
        var result = CDVPluginResult(status: CDVCommandStatus_OK)
        if let _ = dictionary {
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAsDictionary: dictionary)
        }
        self.commandDelegate?.sendPluginResult(result, callbackId: command.callbackId)
    }
}
