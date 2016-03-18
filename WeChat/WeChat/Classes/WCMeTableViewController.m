//
//  WCMeTableViewController.m
//  WeChat
//
//  Created by 倪建 on 16/3/17.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCMeTableViewController.h"
#import "XMPPvCardTemp.h"

@interface WCMeTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;

@property (weak, nonatomic) IBOutlet UILabel *weChatNumLabel;


@end

@implementation WCMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示头像和微信号
    
    //从数据库读取用户信息（不需要直接使用）
    //获取登录用户信息，使用电子名片模块
    //登录用户的电子名片信息
    // 1.它内部会去数据库查找
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    //获取头像
    if (myvCard.photo) {
        self.avatarImage.image = [UIImage imageWithData:myvCard.photo];
    }
    
    //微信号（显示用户名）
    // 为什么jid是空，原因是服务器返回的电子名片xmp数据没有JABBERJID的节点
    //self.weChatNumLabel.text = myvCard.jid.user;
    NSString *weStr = [@"微信号:" stringByAppendingString:[WCAccount shareAccount].loginUser];
    self.weChatNumLabel.text = weStr;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



#pragma mark - 注销
- (IBAction)logoutBtnClick:(id)sender {
    //注销
    
    [[WCXMPPTool sharedWCXMPPTool] xmppLogout];
    
    //注销的时候，把沙盒的登录状态设置为NO
    [WCAccount shareAccount].login = NO;
    [[WCAccount shareAccount] saveToSandBox];
    
    
    //回到登录控制器
    //showInitialVCWithName 显示storyboard的第一个控制器到窗口
    [UIStoryboard showInitialVCWithName:@"Login"];
    
  
}



@end
