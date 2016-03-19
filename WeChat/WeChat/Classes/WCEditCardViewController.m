//
//  WCEditCardViewController.m
//  WeChat
//
//  Created by 倪建 on 16/3/19.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCEditCardViewController.h"

@interface WCEditCardViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;




- (IBAction)saveBtnClick:(id)sender;

@end

@implementation WCEditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = self.cell.textLabel.text;
    
    //设置输入框的默认数值
    self.textField.text = self.cell.detailTextLabel.text;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (IBAction)saveBtnClick:(id)sender {
    // 1. 把cell的detailTextLabel的值更换
    self.cell.detailTextLabel.text = self.textField.text;
    
    [self.cell layoutSubviews];
    
    // 2.当前控制器销毁
    [self.navigationController popViewControllerAnimated:YES];
    
    // 3.把数据保存到服务器
    // 通过上一个服务器
    if([self.delegate respondsToSelector:@selector(editCardViewController:didFinishedSave:)]){
        [self.delegate editCardViewController:self didFinishedSave:sender];
    }
   
}
@end











