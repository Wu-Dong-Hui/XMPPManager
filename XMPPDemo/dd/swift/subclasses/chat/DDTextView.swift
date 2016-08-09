//
//  DDTextView.swift
//  Dong
//
//  Created by darkdong on 15/10/9.
//  Copyright © 2015年 Dong. All rights reserved.
//

import UIKit

class DDTextView: UITextView {
    var shouldResignFirstResponder = true
    
    override func canResignFirstResponder() -> Bool {
        DDLog2.print("DDTextView canResignFirstResponder \(shouldResignFirstResponder)")
        return shouldResignFirstResponder
    }
}