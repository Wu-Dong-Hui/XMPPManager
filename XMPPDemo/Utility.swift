//
//  Utility.swift
//  ZhilianApp
//
//  Created by Roy on 16/5/17.
//  Copyright © 2016年 Facebook. All rights reserved.
//

import UIKit

typealias HttpRequestCompletionHandler = (AnyObject?, NSError?, String?) -> Void
typealias RESTCompletionHandler = (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void


class Utility: NSObject {
    
    static let dateFormatterHM: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static let dateFormatterYMD: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    static let dateFormatterMD: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()
    static let dateFormatterYMDHM: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    static let dateFormatterYMDHMS: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    static let currencyFormatter: NSNumberFormatter = {
       let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencySymbol = ""
        return formatter
    }()
    enum MyResult {
        case Error(NSError)
        case Success(AnyObject, String?)
    }
    
    @objc enum Failure: Int {
        case Fail = -1
        case NotJSON = 9999
        case NoStatusField = 99999
        
        func description() -> String {
            switch self.rawValue {
            case 200:
                return "操作成功"
            case -1:
                return "服务器异常"
            case 400:
                return ""
            default:
                return ""
            }
        }
    }
    
    static func parseResponseJSON(responseObject: AnyObject?) -> MyResult {
        var error: NSError! = nil
        var payload: AnyObject! = nil
        var message: String?
        
        if let json = responseObject as? [String: AnyObject] {
            if let msg = json["msg"] as? String {
                message = msg
            }
            if let status = json["code"] as? Int {
                if 0 == status {
                    payload = json["obj"]
                } else {
                    if let failure = Failure(rawValue: status) {
                        error = NSError(domain: "cn.com.zhaopin.zbproduct", code: status, userInfo: [NSLocalizedDescriptionKey : failure.description()])
                    } else {
                        error = NSError(domain: "UNKONWN ERROR", code: status, userInfo: [NSLocalizedDescriptionKey: message ?? "未知错误"])
                    }
                }
            } else {
                error = NSError(domain: "NO STATUS FIELD", code: Failure.NoStatusField.rawValue, userInfo: [NSLocalizedDescriptionKey: message ?? "缺少status参数"])
            }
        } else {
            error = NSError(domain: "NOT JSON", code: Failure.NotJSON.rawValue, userInfo: [NSLocalizedDescriptionKey: message ?? "返回数据非JSON格式"])
        }
        if payload != nil {
            return MyResult.Success(payload!, message)
        } else {
            return MyResult.Error(error!)
        }
    }
    
    class func parseResponseJSON(json: AnyObject!, completionHandler: HttpRequestCompletionHandler!) {
        let result = self.parseResponseJSON(json)
        switch result {
        case let .Success(dataObj, message):
            if message != nil {
//                SVProgressHUD.showSuccessWithStatus(message)
            }
            completionHandler?(dataObj, nil, message)
        case let .Error(errorToPass):
//            SVProgressHUD.showErrorWithStatus(errorToPass.localizedDescription)
            completionHandler(nil, errorToPass, errorToPass.localizedDescription)
        }
    }
    
    class func parseError(error: NSError) -> NSError {
        var msg: String = ""
        switch error.code {
        case 400...500:
            msg = "网络出错"
        default:
            msg = "未知错误"
            break
        }
        return NSError(domain: "cn.com.zhaopin.zbproduct", code: error.code, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    
    
    private static let manager = Utility.initDefaultSessionManager()
    
    private static func initDefaultSessionManager() -> AFHTTPSessionManager {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: config)
        
        manager.requestSerializer.setValue("1", forHTTPHeaderField: "device-plat")
        
        setHeaderValues()
        
        manager.responseSerializer.acceptableContentTypes = NSSet(arrayLiteral: NSString(string: "text/html"), NSString(string: "application/json"), NSString(string: "text/plain")) as? Set<String>
        return manager
    }
    /**
     将token和device-id加入到请求header中
     */
    static func setHeaderValues() {
        //    if let user = Global.sharedInstance.user {
        //      manager.requestSerializer.setValue(user.token, forHTTPHeaderField: "token")
        //      manager.requestSerializer.setValue(user.deviceId, forHTTPHeaderField: "device-id")
        //    }
    }
    static func addExtParamters(paras: [String: AnyObject]!) -> [String: AnyObject]! {
        var p = paras
        p["x-acl-token"] = "4b4beae9c9994ca1bbf5747f54edac5d"
        return p
    }
    static func get(URLString: String, paras: [String: AnyObject]!, completionHandler: HttpRequestCompletionHandler) -> NSURLSessionDataTask? {
        let parameter = Utility.addExtParamters(paras)
//        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        DDLogInfo("api: \(URLString)\n paras: \(parameter)\n header: \(manager.requestSerializer.HTTPRequestHeaders)")
        return manager.GET(Global.sharedInstance.server + URLString, parameters: parameter, progress: nil, success: { (task, json) in
            DDLogInfo("\(json)")
            self.parseResponseJSON(json, completionHandler: completionHandler)
        }) { (task, error) in
            DDLogError("\(error)")
            let myErr = self.parseError(error)
            completionHandler(nil, myErr, myErr.localizedDescription)
        }
    }
    static func post(URLString: String, paras: [String: AnyObject]!, completionHandler: HttpRequestCompletionHandler) -> NSURLSessionDataTask? {
        let parameter = Utility.addExtParamters(paras)
        DDLogInfo("api: \(URLString)\n paras: \(parameter)\n header: \(manager.requestSerializer.HTTPRequestHeaders)")
        
//        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return manager.POST(Global.sharedInstance.server + URLString, parameters: parameter, progress: nil, success: { (task, json) in
            DDLogInfo("\(json)")
            self.parseResponseJSON(json, completionHandler: completionHandler)
            }, failure: { (task, error) in
                DDLogError("\(error)")
                let myErr = self.parseError(error)
                completionHandler(nil, myErr, myErr.localizedDescription)
        })
    }
    static func post(URLString: String, paras: [String: AnyObject]!, progress: (NSProgress -> Void)?, constructingBodyWithBlock: (AFMultipartFormData -> Void)?, completionHandler: HttpRequestCompletionHandler) -> NSURLSessionDataTask? {
        let parameter = Utility.addExtParamters(paras)
//        manager.requestSerializer.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        DDLogInfo("api: \(URLString)\n paras: \(parameter)\n header: \(manager.requestSerializer.HTTPRequestHeaders)")
        return manager.POST(Global.sharedInstance.server + URLString, parameters: parameter, constructingBodyWithBlock: constructingBodyWithBlock, progress: progress, success: { (task, json) in
            DDLogInfo("\(json)")
            self.parseResponseJSON(json, completionHandler: completionHandler)
        }) { (task, error) in
            DDLogError("\(error)")
            let myErr = self.parseError(error)
            completionHandler(nil, myErr, myErr.localizedDescription)
        }
    }
    
    static func download(URLString: String, progress: (NSProgress -> Void)?, destinationURL: NSURL, completionHandler: ((NSURLResponse, NSURL?, NSError?) -> Void)) -> NSURLSessionDownloadTask? {
        let downloadTask = manager.downloadTaskWithRequest(NSURLRequest(URL: NSURL(string: Global.sharedInstance.server + URLString)!), progress: progress, destination: { (url, response) -> NSURL in
            return destinationURL
            }, completionHandler: completionHandler)
        downloadTask.resume()
        return downloadTask
    }
    static func upload(URLString: String, data: NSData, progress: (NSProgress -> Void)?, completionHandler: ((NSURLResponse, AnyObject?, NSError?) -> Void)) -> NSURLSessionUploadTask? {
        let uploadTask = manager.uploadTaskWithRequest(NSURLRequest(URL: NSURL(string: Global.sharedInstance.server + URLString)!), fromData: data, progress: progress, completionHandler: completionHandler)
        uploadTask.resume()
        return uploadTask
    }
    
    static func currentVisibleController() -> UIViewController {
        let appDelegate = UIApplication.sharedApplication().delegate!
        var rootController = appDelegate.window!!.rootViewController!
        while rootController.presentedViewController != nil {
            rootController = rootController.presentedViewController!
        }
        return rootController
    }
    //  static func setRootViewControllerWithTabBar() {
    //    if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
    //      let tabbarVC = MainTabBarController()
    //      app.window.rootViewController = tabbarVC
    //    }
    //  }
    //  static func setRootViewControllerWithLogin() {
    //    if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
    //      let loginVC = LoginController()
    //      app.window.rootViewController = loginVC
    //    }
    //  }
}
//UI
extension Utility {
    
    
    static func dushBorderImage(size: CGSize, borderWith: CGFloat, borderColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clearColor().set()
        let context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        CGContextSetLineWidth(context, borderWith)
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
        let length: [CGFloat] = [3, 1]
        let biz = UIBezierPath(roundedRect: CGRect(origin: CGPointZero, size: size), cornerRadius: 5)
        CGContextAddPath(context, biz.CGPath)
        CGContextSetLineDash(context, 0, length, 2)
        CGContextStrokePath(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
//checking
extension Utility {
    static func isValidPhoneNumber(checkString: String) -> Bool {
        let phoneRegex = "^1[3|4|5|8][0-9]\\d{8}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluateWithObject(checkString)
    }
    static func isValidPassword(password: String) -> Bool {
        if password.characters.count < 6 || password.characters.count > 20 {
            //too short/long
            return false
        }
        
        let trimmedNumberString = password.stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet())
        if trimmedNumberString.characters.count == 0 {
            return false
        }
        let trimmedUpperString = password.stringByTrimmingCharactersInSet(NSCharacterSet.uppercaseLetterCharacterSet())
        if trimmedUpperString.characters.count == 0 {
            return false
        }
        let trimmedLowerString = password.stringByTrimmingCharactersInSet(NSCharacterSet.lowercaseLetterCharacterSet())
        if trimmedLowerString.characters.count == 0 {
            return false
        }
        
        return true
    }
    static func isValidEmail(email: String) -> Bool {
        return false
    }
    static func isValidIDCard(cardNum: String) -> Bool {
        return true
    }
    
}
//foundation
extension Utility {
    static func attributedString(string: String, font: UIFont, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color])
    }
}