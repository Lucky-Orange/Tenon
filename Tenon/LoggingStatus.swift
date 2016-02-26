//
//  LoginStatus.swift
//  Tenon
//
//  Created by leqicheng on 15/10/9.
//  Copyright © 2015年 乐其橙. All rights reserved.
//

import Pitaya
import JSONNeverDie

class LoggingStatusModel: JSONNDModel {
    var CID = ""
    var GID = ""
    var TuID = ""
    init(CID: String, GID: String, TuID: String) {
        super.init(JSONNDObject: JSONND())
        self.CID = CID
        self.GID = GID
        self.TuID = TuID
    }

    required init(JSONNDObject json: JSONND) {
        super.init(JSONNDObject: json)
    }
}

struct LoggingStatus {
    
    var path: String!

    var data: NSData! {
        get {
            if let data = NSData(contentsOfFile: path) {
                return data
            }
            return nil
        }
    }
    
    init() {
        let fileManager = NSFileManager.defaultManager()
        self.path = NSHomeDirectory().stringByAppendingString("/Documents/LoggingStatus.json")
        if !fileManager.fileExistsAtPath(self.path) {
            if fileManager.createFileAtPath(self.path, contents: NSData(), attributes: nil) {
                do {
                    try "[]".writeToFile(self.path, atomically: false, encoding: NSUTF8StringEncoding)
                } catch {
                    print("写入错误！")
                }
                print("创建成功！")
            }
        }
    }
    
    func writeToFile(array: [JSONND]) {
        var s = "["
        var stringArray = [String]()
        for i in array {
            stringArray.append(i.jsonStringValue)
        }
        let content = stringArray.joinWithSeparator(",\n")
        s.appendContentsOf(content)
        s.appendContentsOf("]")
        do {
            try s.writeToFile(self.path, atomically: false, encoding: NSUTF8StringEncoding)
        } catch {
            print("写入错误！")
        }
    }
    
    func addOneLog(CID: String, GID: String, TuID: String) {
        if let _ = self.data {
            let json = JSONND.initWithData(data)
            if let array = json.array {
                var hasTheRecord = false
                for i in array {
                    let model = LoggingStatusModel(JSONNDObject: i)
                    if model.CID == CID && model.GID == GID && model.TuID == TuID {
                        hasTheRecord = true
                    }
                }
                if !hasTheRecord {
                    var a = array
                    let oneLog: JSONND = ["CID": CID, "GID": GID, "TuID": TuID]
                    a.append(oneLog)
                    self.writeToFile(a)
                }
            }
        }
    }
    
    func removeOneLog(CID: String, GID: String, TuID: String) {
        if let _ = self.data {
            let json = JSONND.initWithData(data)
            if let array = json.array {
                var a = array
                for (i, j) in a.enumerate() {
                    let model = LoggingStatusModel(JSONNDObject: j)
                    if model.CID == CID && model.GID == GID && model.TuID == TuID {
                        a.removeAtIndex(i)
                    }
                }
                self.writeToFile(a)
            }
        }
    }
    
    func isLoggingIn(CID: String, GID: String, TuID: String) -> Bool {
        if let _ = self.data {
            let json = JSONND.initWithData(data)
            if let array = json.array {
                for i in array {
                    let model = LoggingStatusModel(JSONNDObject: i)
                    if model.CID == CID && model.GID == GID && model.TuID == TuID {
                        return true
                    }
                }
            }
        }
        return false
    }
}
