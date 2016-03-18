//
//  WCAccount.m
//  WeChat
//
//  Created by 倪建 on 16/2/15.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCAccount.h"
#define kUserKey @"user"
#define kPwdKey @"pwd"
#define kLoginKey @"login"

static NSString *domain = @"nijiandemacbook-air.local";
static NSString *host = @"127.0.0.1";
static int port = 5222;

@implementation WCAccount

+ (instancetype)shareAccount{
    return [[self alloc]init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    // 为了线程安全
    static WCAccount *acount;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            acount = [super allocWithZone:zone];
            
            //从沙盒获取上次的用户信息
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            acount.loginUser = [defaults objectForKey:kUserKey];
            acount.loginPwd = [defaults objectForKey:kPwdKey];
            acount.login = [defaults boolForKey:kLoginKey];
   
    });
    return acount;
}

- (void)saveToSandBox{
    // 保存user pwd login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.loginUser forKey:kUserKey];
    [defaults setObject:self.loginPwd forKey:kPwdKey];
    [defaults setBool:self.isLogin forKey:kLoginKey];
    [defaults synchronize];
}


-(NSString *)domain{
    return domain;
}
-(NSString *)host{
    return host;
}

-(int)port{
    return port;
}







@end
