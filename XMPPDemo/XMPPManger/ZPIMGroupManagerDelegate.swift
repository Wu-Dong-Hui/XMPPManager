//
//  ZPIMGroupManagerDelegate.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
/**
 离开群组的原因
 
 - beRemoved: 被移除
 - userLeave: 自己离开
 - destroyed: 群组销毁
 */
@objc enum ZPIMLeaveGroupReason: Int {
    case beRemoved
    case userLeave
    case destroyed
}
//MARK: - ZPIMGroupManagerDelegate
/**
 *  群组相关的回调
 */
@objc protocol ZPIMGroupManagerDelegate: NSObjectProtocol {
    /**
     用户A邀请用户B入群，用户B收到该回调
     
     - parameter groupId: 群组id
     - parameter inviter: 邀请者
     - parameter message: 邀请信息
     */
    optional func didReceiveGroupInvitation(groupId: String, inviter: String, message: String)
    /**
     用户B同意用户A的入群邀请后，用户A接收到该回调
     
     - parameter group:   群组实例
     - parameter invitee: 被邀请者
     */
    optional func didReceiveAcceptedGroupInvitation(group: ZPIMGroup, invitee: String)
    /**
     用户B拒绝用户A的入群邀请后，用户A接收到该回调
     
     - parameter group:   群组
     - parameter invitee: 被邀请者
     - parameter reason:  拒绝理由
     */
    optional func didReceiveDeclinedGroupInvitation(group: ZPIMGroup, invitee: String, reason: String)
    /**
     自动同意了用户A的加B入群邀请后，用户B接收到该回调，需要设置ZPIMOptions的autoAcceptGroupInvitation为YES
     
     - parameter group:   群组实例
     - parameter inviter: 邀请者
     - parameter message: 邀请消息
     */
    optional func didJoinedGroup(group: ZPIMGroup, inviter: String, message: String)
    /**
     离开群组回调
     
     - parameter group:  群组实例
     - parameter reason: 离开原因
     */
    optional func didReceiveLeavedGroup(group: ZPIMGroup, reason: ZPIMLeaveGroupReason)
    /**
     群组的群主收到用户的入群申请，群的类型是EMGroupStylePublicJoinNeedApproval
     
     - parameter group:     群组实例
     - parameter applicant: 申请者
     - parameter reason:    申请者的附属信息
     */
    optional func didReceiveJoinGroupApplication(group: ZPIMGroup, applicant: String, reason: String)
    /**
     群主拒绝用户A的入群申请后，用户A会接收到该回调，群的类型是needApproval
     
     - parameter group:  群组ID
     - parameter reason: 拒绝理由
     */
    optional func didReceiveDeclinedJoinGroup(group: ZPIMGroup, reason: String)
    /**
     群主同意用户A的入群申请后，用户A会接收到该回调，群的类型是needApproval
     
     - parameter group: 通过申请的群组
     */
    optional func didReceiveAcceptedJoinGroup(group: ZPIMGroup)
    /**
     群组列表发生变化
     
     - parameter list: 群组列表<EMGroup>
     */
    optional func didUpdateGroupList(list: Array<ZPIMGroup>)
}