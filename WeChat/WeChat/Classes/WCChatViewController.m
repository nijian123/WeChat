//
//  WCChatViewController.m
//  WeChat
//
//  Created by 倪建 on 16/3/20.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCChatViewController.h"

@interface WCChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
/**
 *  输入框容器距离底部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


- (IBAction)imgChooseBtnClick:(id)sender;

@end

@implementation WCChatViewController{
    NSFetchedResultsController *_resultContr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    //加载数据库的聊天数据
    
    // 1.上下文
    NSManagedObjectContext *msgContext = [WCXMPPTool sharedWCXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    
    // 2.查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 过滤 （当前登录用户 并且 好友的聊天消息）
    NSString *loginUserJid = [WCXMPPTool sharedWCXMPPTool].xmppStream.myJID.bare;
    WCLog(@"%@",loginUserJid);
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",loginUserJid,self.friendJid.bare];
    request.predicate = pre;
    
    // 设置时间排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    // 3.执行请求
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *err = nil;
    [_resultContr performFetch:&err];
    WCLog(@"%@",err);
    WCLog(@"%@",_resultContr.fetchedObjects);

    
    
    
}

#pragma mark - 数据库内容改变调用
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    [self.tableView reloadData];
    
    //表格滚动到底部
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_resultContr.fetchedObjects.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}
#pragma mark - tableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _resultContr.fetchedObjects.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"ChatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID
                             ];
    
    //获取聊天信息
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = _resultContr.fetchedObjects[indexPath.row];
    
    //判断消息的类型，是否有附件
    // 1.获取原始的xml数据
    XMPPMessage *message = msgObj.message;
    
    // 获取附件类型
    NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
    
    if ([bodyType isEqualToString:@"image"]) { // 图片
        // 2.遍历message的子节点
        NSArray *child = message.children;
        for (XMPPElement *note in child) {
            // 获取节点的名字
            NSString *nameStr = [note name];
            if ([nameStr isEqualToString:@"attachment"]) {
                WCLog(@"获取到附件");
                // 获取附件字符串，然后转成NSData，接着转成图片
                NSString *imgBase64Str = [note stringValue];
                
                NSData *imgData = [[NSData alloc]initWithBase64EncodedString:imgBase64Str options:0];
                
                UIImage *img = [UIImage imageWithData:imgData];
                cell.imageView.image = img;
                
            }
            
        }

        
    }
    if ([bodyType isEqualToString:@"sound"]) { //音频
        
        
    }else{ // 纯文本
        
        cell.textLabel.text = msgObj.body;

    }
    
    
    
    
    
    
    return cell;
}

#pragma mark - 键盘的通知
#pragma mark 键盘将显示
-(void)kbWillShow:(NSNotification *)noti{
    //显示的时候改变bottomContraint
    
    // 获取键盘高度
    NSLog(@"%@",noti.userInfo);
    CGFloat kbHeight = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    
    self.bottomConstraint.constant = -kbHeight;
    
}


#pragma mark 键盘将隐藏
-(void)kbWillHide:(NSNotification *)noti{
    self.bottomConstraint.constant = 0;
    
}


#pragma mark 发送聊天数据
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSString *txt = textField.text;
    
    //怎么发聊天数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    [msg addBody:txt];
    
    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
    
    // 清空输入框的文本
    textField.text = nil;
    
    return YES;
    
}


#pragma mark 表格滚动，隐藏键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
    
}



#pragma mark 文件发送(以图片发送为例)
- (IBAction)imgChooseBtnClick:(id)sender {
    
    //从图片库选取图片
    UIImagePickerController *imgPC = [[UIImagePickerController alloc] init];
    imgPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //imgPC.allowsEditing = YES;
    imgPC.delegate = self;
    
    [self presentViewController:imgPC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    
    // 发送附件
    //[self sendAttachmentWithImage:img];
    
    [self sendAttachmentWithData:UIImagePNGRepresentation(img) bodyType:@"image"];
    
    //移除图片选择控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

#pragma mark 发送图片附件

- (void)sendAttachmentWithData:(NSData *)data bodyType:(NSString *)bodyType{
    /** 创建子节点
     *  将子节点添加到发送消息中 （图片需要转码）
     *  发送
     */
    
    
    // 发送图片
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    //设置类型
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    
    
#pragma mark 没有body就不认
    [msg addBody:bodyType];

    //[msg addBody:@"image"];
    //    [msg addBody:@"sound"];
    //    [msg addBody:@"doc"];
    //    [msg addBody:@"xls"];
    
    //把附件经过base64编码转成字符串
   
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    
   
    
    //定义附件  定义一个子节点
    XMPPElement *attachmet = [XMPPElement elementWithName:@"attachment" stringValue:base64Str];
    
    //添加子节点
    [msg addChild:attachmet];
    
    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
    
}



//- (void)sendAttachmentWithImage:(UIImage *)img{
//    /** 创建子节点
//     *  将子节点添加到发送消息中 （图片需要转码）
//     *  发送
//     */
//    
//    
//    // 发送图片
//    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
// 
//    #pragma mark 没有body就不认
//    [msg addBody:@"image"];
//    //    [msg addBody:@"sound"];
//    //    [msg addBody:@"doc"];
//    //    [msg addBody:@"xls"];
//    
//    //把图片经过base64编码转成字符串
//    // 1. 吧图片转成NSData
//    NSData *imgData = UIImagePNGRepresentation(img);
//    
//    // 2.把data转成base64的字符串
//    NSString *imgBaseStr = [imgData base64EncodedStringWithOptions:0];
//    
//    //定义附件  定义一个子节点
//    XMPPElement *attachmet = [XMPPElement elementWithName:@"attachment" stringValue:imgBaseStr];
//    
//    //添加子节点
//    [msg addChild:attachmet];
//    
//    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
//
//}




@end
