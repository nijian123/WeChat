//
//  WCRegisterViewController.m
//  WeChat
//
//  Created by 倪建 on 16/3/17.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCRegisterViewController.h"

@interface WCRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;



- (IBAction)cancelBtnClick:(id)sender;
- (IBAction)registerBtnClick:(id)sender;


@end

@implementation WCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelBtnClick:(id)sender {
    
    
    
}

- (IBAction)registerBtnClick:(id)sender {
    
    //保存用户的注册名和密码
    [WCAccount shareAccount].registerUser = self.userField.text;
    [WCAccount shareAccount].registerPwd = self.pwdField.text;
    
    [MBProgressHUD showMessage:@"正在注册中。。。。"];
    //调用注册的方法
    
    __weak typeof(self) selfVc = self;
    [WCXMPPTool sharedWCXMPPTool].registerOperation = YES;
    [[WCXMPPTool sharedWCXMPPTool] xmppRegister:^(XMPPResultType resultType) {
        [selfVc handleXMPPResultType:resultType];
        
    }];
    
}


- (void)handleXMPPResultType:(XMPPResultType)resultType{
    dispatch_async(dispatch_get_main_queue(), ^{
       // 1.隐藏提示
        [MBProgressHUD hideHUD];
        
        // 2.提示注册成功
        if (resultType == XMPPResultRegisterSucess) {
            [MBProgressHUD showSuccess:@"恭喜注册成功，回到登录界面登录。。。"];
        }
        if (resultType == XMPPResultRegisterFailure) {
            [MBProgressHUD showError:@"用户名重复"];
        }
    });
    
    
    
}
@end







