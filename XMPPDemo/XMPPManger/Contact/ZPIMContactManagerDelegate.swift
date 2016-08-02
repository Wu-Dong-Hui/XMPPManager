//
//  ZPIMContactManagerDelegate.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
//MARK: - ZPIMContactManagerDelegate
/**
 *  好友相关回调
 */
@objc protocol ZPIMContactManagerDelegate: NSObjectProtocol {
    /**
     用户B同意用户A的加好友请求后，用户A会收到这个回调
     
     - parameter userName: 用户B
     */
    optional func didReceiveAgreedFromUserName(userName: String)
    /**
     用户B拒绝用户A的加好友请求后，用户A会收到这个回调
     - parameter userName: 用户B
     */
    optional func didReceiveDeclinedFromUserName(userName: String)
    /**
     用户B删除与用户A的好友关系后，用户A会收到这个回调
     
     - parameter userName: 用户B
     */
    optional func didReceiveDeletedFromUserName(userName: String)
    /**
     用户B同意用户A的好友申请后，用户A和用户B都会收到这个回调
     
     - parameter userName: 用户好友关系的另一方
     */
    optional func didReceiveAddedFromUserName(userName: String)
    /**
     用户B申请加A为好友后，用户A会收到这个回调
     - parameter userName: 用户B
     - parameter message:  好友邀请信息
     */
    optional func didReceiveFriendInvitationFromUserName(userName: String, message:String)
}