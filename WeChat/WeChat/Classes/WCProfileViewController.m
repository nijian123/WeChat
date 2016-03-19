//
//  WCProfileViewController.m
//  WeChat
//
//  Created by 倪建 on 16/3/18.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "WCEditCardViewController.h"

@interface WCProfileViewController ()<WCEditCardViewControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

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

#pragma mark - 表格选择

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //根据cell不同tag进行相应的操作
    //tag = 0 换头像
    //tag = 1 进行到下一个控制器
    //tag = 2 不做任何操作
   
    // 获取cell
    UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    switch (selectCell.tag) {
        case 0:
            [self chooseImg];
            
            break;
            
        case 1:
            //进行到下一个控制器，把本cell 通过segue进行传递
            [self performSegueWithIdentifier:@"toEditVcSegue" sender:selectCell];

            break;
        case 2:
            
            
            break;
            
        default:
            break;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //获取目标控制器
    id destVc = segue.destinationViewController;
    
    //设置编辑电子名片控制器的cell属性
    if ([destVc isKindOfClass:[WCEditCardViewController class]]) {
        WCEditCardViewController *editVc = destVc;
        // 把本cell  传递给目标控制器
        editVc.cell = sender;
        //设置代理
        editVc.delegate = self;
        
    }
    
}

#pragma mark 选择图片
- (void)chooseImg{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"图片库", nil];
    [sheet showInView:self.view];
    
}
// 代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    WCLog(@"%ld",buttonIndex);
    if (buttonIndex == 2) return;
    
    UIImagePickerController *imgPc = [[UIImagePickerController alloc]init];
    //设置代理
    imgPc.delegate = self;
    //允许编辑图片
    
    imgPc.allowsEditing = YES;
    
    if (buttonIndex == 0) {
        //照相
        imgPc.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }else{
        //图片库
        imgPc.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //显示控制器
    [self presentViewController:imgPc animated:YES completion:nil];
}

#pragma mark 实现图片代理
//完成选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    // 获取修改后的图片
    UIImage *editedImg = info[UIImagePickerControllerEditedImage];
    
    //更改cell里的图片
    self.avatarImgView.image = editedImg;
    
    //移除图片选择的控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //把新的图像保存到服务器
    [self editCardViewController:nil didFinishedSave:nil];
    
    
}


#pragma mark - 编辑电子名片控制器的代理
- (void)editCardViewController:(WCEditCardViewController *)editVc didFinishedSave:(id)sender{
    //获取当前电子名片
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    //重新设置头像
    myvCard.photo= UIImageJPEGRepresentation(self.avatarImgView.image, 0.75);
    
    //重新设置myVcard 的属性
    myvCard.nickname = self.nicknameLabel.text;
    myvCard.orgName = self.orgnameLabel.text;
    
    if (self.departmentLabel.text != nil) {
        myvCard.orgUnits = @[self.departmentLabel.text];
    }
    
    myvCard.title = self.telLabel.text;
    myvCard.note = self.telLabel.text;
    myvCard.mailer = self.emailLabel.text;
    
    //把数据保存到服务器
    //内部实现数据上传 是把整个电子名片数据都上传一次
    [[WCXMPPTool sharedWCXMPPTool].vCard updateMyvCardTemp:myvCard];
}



@end









