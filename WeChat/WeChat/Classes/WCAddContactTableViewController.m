//
//  WCAddContactTableViewController.m
//  WeChat
//
//  Created by 倪建 on 16/3/20.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCAddContactTableViewController.h"

@interface WCAddContactTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;


- (IBAction)addContactClick:(id)sender;


@end

@implementation WCAddContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}





- (IBAction)addContactClick:(id)sender {
    //添加好友
    //获取用户输入好友名称
    NSString *user = nil;
    XMPPJID *userjid = nil;
    if (self.textField.text) {
        user = self.textField.text;
        userjid = [XMPPJID  jidWithUser:user domain:[WCAccount shareAccount].domain resource:nil];
    }
    if(user == nil){
        [self showMsg:@"请输入好友"];
        return;
    }
    
    
    // 1.不能添加自己为好友
    if ([user isEqualToString:[WCAccount shareAccount].loginUser]) {
        [self showMsg:@"不能添加自己为好友"];
        return;
    }
    
    
    // 2.已经存在的好友无需添加
    BOOL userExists = [[WCXMPPTool sharedWCXMPPTool].rosterStorage userExistsWithJID:userjid xmppStream:[WCXMPPTool sharedWCXMPPTool].xmppStream];
    if (userExists) {
        [self showMsg:@"好友已经存在"];
        return;
    }
    
    // 3.添加好友(订阅)
    [[WCXMPPTool sharedWCXMPPTool].roster subscribePresenceToUser:userjid];
   
    
    /*添加好友在现有openfire存在的问题
     1.添加不存在的好友，通讯录里面也现示了好友
     解决办法1. 服务器可以拦截好友添加的请求，如当前数据库没有好友，不要返回信息
     <presence type="subscribe" to="werqqrwe@teacher.local"><x xmlns="vcard-temp:x:update"><photo>b5448c463bc4ea8dae9e0fe65179e1d827c740d0</photo></x></presence>
     
     解决办法2.过滤数据库的Subscription字段查询请求
     none 对方没有同意添加好友
     to 发给对方的请求
     from 别人发来的请求
     both 双方互为好友
     
     */
    
    
    
    
}

- (void)showMsg:(NSString *)msg{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    
    [av show];
 
}


@end









