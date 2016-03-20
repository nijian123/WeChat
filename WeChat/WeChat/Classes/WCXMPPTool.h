//
//  WCXMPPTool.h
//  WeChat
//
//  Created by 倪建 on 16/3/17.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"


typedef enum {
    XMPPResultLoginSucess, //登录成功
    XMPPResultLoginFailure, //登录失败
    XMPPResultRegisterSucess, //注册成功
    XMPPResultRegisterFailure //注册失败
    
}XMPPResultType;

// 与服务器交互的结果  全局块
typedef void (^XMPPResultBlock) (XMPPResultType);

@interface WCXMPPTool : NSObject
singleton_interface(WCXMPPTool)


@property (strong, nonatomic ,readonly) XMPPStream *xmppStream; //与服务器交互的核心类

// 标识连接服务器时，是登录连接还是注册连接
// NO代表登录   YES 代表注册
@property (assign,nonatomic,getter=isRegisterOperation) BOOL registerOperation;

//电子名片模块
@property (strong, nonatomic ,readonly) XMPPvCardTempModule *vCard;

//电子名片数据存储
@property (strong,nonatomic,readonly) XMPPvCardCoreDataStorage *vCardStorage;


@property (strong, nonatomic ,readonly) XMPPRoster *roster; //花名册
@property (strong, nonatomic ,readonly) XMPPRosterCoreDataStorage *rosterStorage; // 花名册数据存储

@property (strong, nonatomic ,readonly) XMPPvCardAvatarModule *avatar; //电子名片的头像模块


//XMPP用户登录
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

//XMPP用户注销
- (void)xmppLogout;

//XMPP用户注册
- (void)xmppRegister:(XMPPResultBlock)resultBlock;

@end









