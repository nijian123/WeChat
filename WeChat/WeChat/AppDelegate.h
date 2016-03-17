//
//  AppDelegate.h
//  WeChat
//
//  Created by 倪建 on 16/2/14.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XMPPResultLoginSucess, //登录成功
    XMPPResultLoginFailure //登录失败
}XMPPResultType;

// 与服务器交互的结果  全局块
typedef void (^XMPPResultBlock) (XMPPResultType);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


//XMPP用户登录
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

@end

