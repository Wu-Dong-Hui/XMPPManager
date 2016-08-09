//
//  DDOptionButton.swift
//  Dong
//
//  Created by darkdong on 15/4/8.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDOptionButton: UIView {
    var buttons: [UIButton]!
    var selectedButton: UIButton!
    var optionDidSelectHandler: ((AnyObject) -> Void)!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.buttons = []
    }
    
    func selectButton(button: UIButton) {
        for btn in self.buttons {
            btn.selected = false
        }
        button.selected = true
        self.selectedButton = button
    }
    
    override func didAddSubview(subview: UIView) {
        if let button = subview as? DDButton {
            button.touchUpInsideHandler = { [weak self] btn in
                self?.selectButton(btn)
                self?.optionDidSelectHandler?(btn)
                return
            }
            self.buttons.append(button)
        }
    }
    
    override func willRemoveSubview(subview: UIView) {
        if let button = subview as? DDButton {
            let buttons = self.buttons.filter({ (btn) -> Bool in
                return button !== btn
            })
            self.buttons = buttons
        }
    }
}
