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
    
    
    
    
    
}

- (void)showMsg:(NSString *)msg{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    
    [av show];
 
}


@end









