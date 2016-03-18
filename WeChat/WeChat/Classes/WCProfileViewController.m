//
//  WCProfileViewController.m
//  WeChat
//
//  Created by 倪建 on 16/3/18.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCProfileViewController.h"
#import "XMPPvCardTemp.h"

@interface WCProfileViewController ()

//图像
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
//昵称
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
//微信号
@property (weak, nonatomic) IBOutlet UILabel *weChatLabel;
//公司
@property (weak, nonatomic) IBOutlet UILabel *orgnameLabel;
//部门
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
//职位
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//电话
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
//邮箱
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation WCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.它内部会去数据库查找
    // 电子名片模型是temp，解析电子名片的xml没有完善，有些节点并未解析，所以称为临时
    
    
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    //获取头像
    if (myvCard.photo) {
        self.avatarImgView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    //微信号（显示用户名）
    self.weChatLabel.text = [WCAccount shareAccount].loginUser;
    //昵称
    self.nicknameLabel.text = myvCard.nickname;
    //公司
    self.orgnameLabel.text = myvCard.orgName;
    //部门
    if (myvCard.orgUnits.count>0) {
        self.departmentLabel.text = myvCard.orgUnits[0];
    }
    //职位
    self.titleLabel.text = myvCard.title;
    //电话 没有解析
    //使用note充当电话
    self.telLabel.text = myvCard.note;
    
    //邮箱 没有解析
    self.emailLabel.text = myvCard.mailer;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
