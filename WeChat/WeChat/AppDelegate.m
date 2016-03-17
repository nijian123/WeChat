//
//  AppDelegate.m
//  WeChat
//
//  Created by 倪建 on 16/2/14.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //判断用户是否登陆
    if([WCAccount shareAccount].login){
        // 1. 获取Main.storyboard的第一个根控制器
        id mainVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        
        // 2. 切换window的根控制器
        // [UIApplication sharedApplication].keyWindow.rootViewController = mainVc;
        self.window.rootViewController = mainVc;
        
        //自动登录
        [[WCXMPPTool sharedWCXMPPTool] xmppLogin:nil];
   
    }
    return YES;
}



@end




























