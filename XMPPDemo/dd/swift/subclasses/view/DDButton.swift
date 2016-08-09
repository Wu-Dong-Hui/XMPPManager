//
//  DDButton.swift
//  Dong
//
//  Created by darkdong on 14-8-4.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit

typealias DDButtonEventHandler = (UIButton!) -> Void

class DDButton: UIButton {
    override var highlighted: Bool {
        willSet {
            func setSubviewsHighlighted(highlighted: Bool) {
                for view in self.subviews {
                    if let label = view as? UILabel {
                        label.highlighted = highlighted
                    }else if let imgview = view as? UIImageView {
                        imgview.highlighted = highlighted
                    }
                }
            }
            setSubviewsHighlighted(newValue)
        }
    }

    var touchUpInsideHandler: DDButtonEventHandler? {
        willSet {
            let action: Selector = #selector(DDButton.handleTouchUpInsideEvent)
            let event: UIControlEvents = .TouchUpInside
            
            if newValue != nil {
                self.addTarget(self, action: action, forControlEvents: event)
            }else {
                self.removeTarget(self, action: action, forControlEvents: event)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    deinit {
//        NSLog("DDButton deinit label: \(self.titleLabel?.text)")
    }
        
    func handleTouchUpInsideEvent() {
        self.touchUpInsideHandler?(self)
    }
}
