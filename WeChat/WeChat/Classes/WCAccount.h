//
//  WCAccount.h
//  WeChat
//
//  Created by 倪建 on 16/2/15.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCAccount : NSObject

//用户登录的账号
@property (nonatomic,copy) NSString *loginUser;
@property (nonatomic,copy) NSString *loginPwd;
//判断用户是否登陆
//get 方法 isLogin
@property (nonatomic,assign,getter=isLogin) BOOL login;

//用户注册的账号
@property (nonatomic,copy) NSString *registerUser;
@property (nonatomic,copy) NSString *registerPwd;



+ (instancetype)shareAccount;

// 保存最新的用户登陆数据到沙盒里面
- (void)saveToSandBox;

@end
