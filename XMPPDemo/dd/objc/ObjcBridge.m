//
//  ObjcBridge.m
//  Dong
//
//  Created by darkdong on 15/7/31.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

#import "ObjcBridge.h"

@implementation ObjcBridge
+ (CIImage *)CIImageFromCGImage:(CGImageRef)cgImage {
    return [CIImage imageWithCGImage:cgImage];
}
@end

@implementation UIBarButtonItem (Appearance_Swift)
+ (instancetype)objcAppearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end

@implementation UIView (Appearance_Swift)
+ (instancetype)objcAppearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end

