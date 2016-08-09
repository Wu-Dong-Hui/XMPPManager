//
//  ALAssetsGroupExtension.swift
//  Dong
//
//  Created by darkdong on 14-10-15.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import Foundation
import AssetsLibrary

extension ALAssetsGroup {
    var name: String! {
        return self.valueForProperty(ALAssetsGroupPropertyName) as! String
    }
    
    var type: ALAssetsGroupType! {
        return self.valueForProperty(ALAssetsGroupPropertyType) as! ALAssetsGroupType
    }
}