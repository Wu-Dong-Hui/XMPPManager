//
//  LogFormatter.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
class LumberjackTTYFormatter: NSObject, DDLogFormatter {
    func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        return "\(NSDate().dateByAddingTimeInterval(8 * 60 * 60)):[file \(logMessage.fileName)] ~ [func \(logMessage.function)] ~ [line \(logMessage.line)] ~~ \(logMessage.message)"
    }
}