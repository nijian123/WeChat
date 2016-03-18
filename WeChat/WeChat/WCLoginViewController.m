//
//  WCLoginViewController.m
//  WeChat
//
//  Created by 倪建 on 16/2/15.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCLoginViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD+HM.h"


@interface WCLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation WCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)loginBtnClick:(id)sender {
    
    // 1. 判断有没有输入用户名和密码
    if (self.userField.text.length == 0 || self.passwordField.text.length == 0) {
        WCLog(@"请输入用户名和密码");
        return;
    }
    
    // 给用户提示
    [MBProgressHUD showMessage:@"正在登陆ing。。。。。"];
    
    // 2. 登录服务器
    
    // 2.1 把用户名和密码先放到Account单例里面
    WCAccount *account = [WCAccount shareAccount];
    account.loginUser = self.userField.text;
    account.loginPwd = self.passwordField.text;
 
    // 2.2 调用APPDelegate的xmppLogin方法
    
    // 怎么把APPDelegate的登录结果告诉WCLoginController控制器
    // 1,代理
    // 2,block
    // 3,通知
    
    //block会对self进行强引用
    //自己写的block，有强引用的时候，使用弱引用。系统block，我们基本可以不理
    
    __weak typeof(self) selfVc = self;
    // 设置标识
    [WCXMPPTool sharedWCXMPPTool].registerOperation = NO;
    
    [[WCXMPPTool sharedWCXMPPTool] xmppLogin:^(XMPPResultType resultType) {
        [selfVc handleXMPPResultType:resultType];
    }];
}

// 处理登录的结果
- (void)handleXMPPResultType:(XMPPResultType)resultType{
    
    //主线程处理结果 更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 隐藏提示框
        [MBProgressHUD hideHUD];
        
        if (resultType == XMPPResultLoginSucess) {
            WCLog(@"登录成功");
            
            
            // 3. 登录成功切换到主界面
           // [self changeToMain];
            [UIStoryboard showInitialVCWithName:@"Main"];
            
            // 保存登陆的账户信息到沙盒里面
            [WCAccount shareAccount].login = YES;
            [[WCAccount shareAccount] saveToSandBox];
        
        }else{
            WCLog(@"登录失败");
            
            
            [MBProgressHUD showError:@"用户名或密码错误"];
        }
    });
}


#pragma mark -切换到主界面
//- (void)changeToMain{
//    // 回到主线程更新UI
//    
//        // 1. 获取Main.storyboard的第一个根控制器
//        id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
//        
//        // 2. 切换window的根控制器
//        [UIApplication sharedApplication].keyWindow.rootViewController = vc;
//}










@end
