//
//  DDUploader.swift
//  Dong
//
//  Created by darkdong on 15/7/27.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import Foundation

let DDNotificationNameFileUploadWillStart = "DDNotificationNameFileUploadWillStart"
let DDNotificationNameFileUploadDidEnd = "DDNotificationNameFileUploadDidEnd"

private var observeContextProgress = 0

class DDUploader {
    static let sharedUploader = DDUploader(infoDirectoryName: "uploadInfo", dataDirectoryName: "uploadData")
    
    static let InfoKeyMethod = "method"
    static let InfoKeyURL = "URL"
    static let InfoKeyParameters = "parameters"
    static let InfoKeyHeaderFields = "headerFields"
    static let InfoKeyHeaderFieldName = "headerFieldName"
    static let InfoKeyHeaderFieldValue = "headerFieldValue"
//    static let InfoKeyMultiparts = "multiparts"
    static let InfoKeyMultipartFieldName = "multipartFieldName"
    static let InfoKeyMultipartDataFilename = "multipartDataFilename"
    static let InfoKeyTimeout = "timeout"
    static let InfoKeyShouldDeleteDataFileWhenDone = "shouldDeleteDataFileWhenDone"
    static let InfoKeyCustomInfo = "customInfo"

    let infoDirectoryURL: NSURL
    let dataDirectoryURL: NSURL

//    weak var progress: NSProgress?
    var isUploading = false
    var info: [String: AnyObject]? = nil
    var task: NSURLSessionTask? = nil
    
    enum FileUploadingOrder {
        case DateName
        case Name
    }
    var fileUploadingOrder = FileUploadingOrder.Name
    var responseSuccessPredicate: ((AnyObject) -> Bool)?
    var shouldStartUploading: (() -> Bool)?
    var backgroundTaskIdentifier = UIBackgroundTaskInvalid
    var shouldExecuteInBackground = true
    
    init(infoDirectoryName: String, dataDirectoryName: String) {
        NSLog("DDUploader infoDirectoryName \(infoDirectoryName) dataDirectoryName \(dataDirectoryName)")
        let documentDirURL = NSURL.URLForDirectory(.DocumentDirectory)
        infoDirectoryURL = documentDirURL.URLByAppendingPathComponent(infoDirectoryName).createDirectory()
        dataDirectoryURL = documentDirURL.URLByAppendingPathComponent(dataDirectoryName).createDirectory()
    }
    
    //MARK: - private
    func firstInfoFileToUpload() -> NSURL? {
        var targetFileURL: NSURL? = nil
        var targetFileLeastName: String? = nil
        
        let manager = NSFileManager.defaultManager()
        let fileURLs = (try! manager.contentsOfDirectoryAtURL(infoDirectoryURL, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)) 
        
        switch(self.fileUploadingOrder) {
        case .DateName:
            var targetFileEarliestDate: NSDate? = nil
            for fileURL in fileURLs {
                if let filePath = fileURL.path, info = try? manager.attributesOfItemAtPath(filePath), creationDate = info[NSFileCreationDate] as? NSDate {
                    let fileName = fileURL.lastPathComponent
                    if targetFileEarliestDate == nil || creationDate.timeIntervalSince1970 < targetFileEarliestDate!.timeIntervalSince1970 {
                        //按创建时间比较，取较早的
                        targetFileEarliestDate = creationDate
                        targetFileLeastName = fileName
                        targetFileURL = fileURL
                    }else if creationDate.timeIntervalSince1970 == targetFileEarliestDate!.timeIntervalSince1970 {
                        //相同创建时间，看文件名
                        if targetFileLeastName == nil || fileName < targetFileLeastName {
                            targetFileLeastName = fileName
                            targetFileURL = fileURL
                        }
                    }
                }
            }
            return targetFileURL
        case .Name:
            for fileURL in fileURLs {
                if let fileName = fileURL.lastPathComponent {
                    //按文件名
                    if targetFileLeastName == nil || fileName < targetFileLeastName {
                        targetFileLeastName = fileName
                        targetFileURL = fileURL
                    }
                }
            }
            return targetFileURL
        }
    }
    
    func setShouldExecuteInBackground() {
        if (backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
            let app = UIApplication.sharedApplication()
            backgroundTaskIdentifier = app.beginBackgroundTaskWithExpirationHandler{ [weak self] () -> Void in
                self?.task?.cancel()
                if let backgroundTaskId = self?.backgroundTaskIdentifier {
                    app.endBackgroundTask(backgroundTaskId)
                }
                self?.backgroundTaskIdentifier = UIBackgroundTaskInvalid
            }
        }
    }
    
    func isUploadingSuccess(responseObject: AnyObject!) -> Bool {
        if let obj: AnyObject = responseObject {
            if self.responseSuccessPredicate == nil {
                return true
            }else if let isUploadSuccess = self.responseSuccessPredicate where isUploadSuccess(obj) {
                return true
            }
        }
        return false
    }
    
    func uploadNext() {
        self.isUploading = false
        self.task = nil
        NSNotificationCenter.defaultCenter().postNotificationName(DDNotificationNameFileUploadDidEnd, object: self, userInfo: self.info)
        self.upload()
    }
    //MARK: - public
    func upload() {
        if isUploading {
            return
        }
        
        if let shouldStartUploading = shouldStartUploading where !shouldStartUploading() {
            return
        }
        
        DDLog2.log("DDUploader: main? \(NSThread.isMainThread())")

        if let infoFileURL = self.firstInfoFileToUpload(), infoObject = NSDictionary(contentsOfURL: infoFileURL) as? [String: AnyObject] {
            DDLog2.log("DDUploader: info file \(infoFileURL) infoObject \(infoObject)")
            info = infoObject
            NSNotificationCenter.defaultCenter().postNotificationName(DDNotificationNameFileUploadWillStart, object: self, userInfo: infoObject)
            
            let method = infoObject[DDUploader.InfoKeyMethod] as! String
            let urlString = infoObject[DDUploader.InfoKeyURL] as! String
            
            let parameters = infoObject[DDUploader.InfoKeyParameters] as? [String: AnyObject]
            let timeout = infoObject[DDUploader.InfoKeyTimeout] as? NSTimeInterval
            
            DDLog2.log("DDUploader: method \(method) urlString \(urlString) parameters \(parameters) timeout \(timeout)")
            
            if self.shouldExecuteInBackground {
                self.setShouldExecuteInBackground()
            }
            
            let isMultipart: Bool
            let request: NSMutableURLRequest
            let completionHandler: (NSURLResponse?, AnyObject?, NSError?) -> Void
            
            if let fieldName = infoObject[DDUploader.InfoKeyMultipartFieldName] as? String, dataFilename = infoObject[DDUploader.InfoKeyMultipartDataFilename] as? String {
                let dataFileURL = dataDirectoryURL.URLByAppendingPathComponent(dataFilename)
                DDLog2.log("DDUploader: multipart request file \(dataFileURL) fieldName \(fieldName)")
                isMultipart = true
                request = AFHTTPRequestSerializer().multipartFormRequestWithMethod(method, URLString: urlString, parameters: parameters, constructingBodyWithBlock: { (formData: AFMultipartFormData) -> Void in
                    do {
                        try formData.appendPartWithFileURL(dataFileURL, name: fieldName)
                    }catch {
                    }
                    }, error: nil)
                let shouldDeleteDataFileWhenDone = infoObject[DDUploader.InfoKeyShouldDeleteDataFileWhenDone] as? Bool ?? true
                completionHandler = { [weak self] response, responseObject, error -> Void in
                    DDLog2.log("DDUploader: multipart completionHandler \(responseObject)")
                    
                    if let success = self?.isUploadingSuccess(responseObject) where success {
                        let manager = NSFileManager.defaultManager()
                        do {
                            try manager.removeItemAtURL(infoFileURL)
                        } catch _ {
                        }
                        
                        if shouldDeleteDataFileWhenDone {
                            do {
                                try manager.removeItemAtURL(dataFileURL)
                            } catch _ {
                            }
                        }
                    }
                    self?.uploadNext()
                }
            }else {
                DDLog2.log("DDUploader: general request")
                isMultipart = false
                request = AFHTTPRequestSerializer().requestWithMethod(method, URLString: urlString, parameters: parameters, error: nil)
                completionHandler = { [weak self] response, responseObject, error -> Void in
                    DDLog2.log("DDUploader: general completionHandler \(responseObject)")
                    if let success = self?.isUploadingSuccess(responseObject) where success {
                        let manager = NSFileManager.defaultManager()
                        do {
                            try manager.removeItemAtURL(infoFileURL)
                        } catch _ {
                        }
                    }
                    self?.uploadNext()
                }
            }
            
            //add header fileds if any
            if let headerFields = infoObject[DDUploader.InfoKeyHeaderFields] as? [AnyObject] {
                for headerField in headerFields {
                    if let field = headerField as? [String: String], fieldName = field[DDUploader.InfoKeyHeaderFieldName], fieldValue = field[DDUploader.InfoKeyHeaderFieldValue] {
                        request.addValue(fieldValue, forHTTPHeaderField: fieldName)
                    }
                }
            }
            //add timeout if any
            if let timeout = timeout {
                request.timeoutInterval = timeout
            }
            
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let sessionManager = AFURLSessionManager(sessionConfiguration: sessionConfig)
            
            if isMultipart {
                task = sessionManager.uploadTaskWithStreamedRequest(request, progress: nil, completionHandler: completionHandler)
            }else {
                // need test
//                task = sessionManager.dataTaskWithRequest(request, completionHandler: completionHandler)
                task = sessionManager.dataTaskWithRequest(request, uploadProgress: nil, downloadProgress: nil, completionHandler: completionHandler)
            }
            //                progress?.addObserver(self, forKeyPath: "fractionCompleted", options: .New, context: &observeContextProgress)
            task?.resume()
            isUploading = true
        }else {
            //no info file to upload, remove alldata files
            DDLog2.print("DDUploader: no info file to upload")
        }
    }
    
    //MARK: - KVO upload progress
    
    //    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
    //        if context == &observeContextProgress {
    ////            let progress = object as! NSProgress
    //            DDLog2.log("object \(object) change \(change)")
    //        }else {
    //            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    //        }
    //    }
}