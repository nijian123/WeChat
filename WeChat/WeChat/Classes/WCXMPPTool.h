//
//  WCXMPPTool.h
//  WeChat
//
//  Created by 倪建 on 16/3/17.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"


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

// 标识连接服务器时，是登录连接还是注册连接
// NO代表登录   YES 代表注册
@property (assign,nonatomic,getter=isRegisterOperation) BOOL registerOperation;

//XMPP用户登录
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

//XMPP用户注销
- (void)xmppLogout;

//XMPP用户注册
- (void)xmppRegister:(XMPPResultBlock)resultBlock;

@end









