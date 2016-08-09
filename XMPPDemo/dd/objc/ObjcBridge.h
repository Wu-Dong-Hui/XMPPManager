//
//  ObjcBridge.h
//  Dong
//
//  Created by darkdong on 15/7/31.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjcBridge : NSObject
+ (CIImage *)CIImageFromCGImage:(CGImageRef)cgImage;
@end

@interface UIBarItem (Appearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)objcAppearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end

@interface UIView (Appearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)objcAppearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
