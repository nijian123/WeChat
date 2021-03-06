//
//  WCContactTableViewController.m
//  WeChat
//
//  Created by 倪建 on 16/3/19.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCContactTableViewController.h"
#import "WCChatViewController.h"

@interface WCContactTableViewController ()<NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *_resultContr;
}

/**
 * 好友
 */
@property(strong,nonatomic)NSArray *users;

@end

@implementation WCContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self loadUser1];
    [self loadUesr2];
    
    
}

#pragma mark 加载好友数据方法1
- (void)loadUser1{
    
    //显示好友数据 保存XMPPRoster.sqlite文件
    //1.上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2.Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //3.执行请求
    //3.1创建结果控制器
    // 数据库查询，如果数据很多，会放在子线程查询
    // 移动客户端的数据库里数据不会很多，所以很多数据库的查询操作都主线程
    NSError *error;
    NSArray *users = [rosterContext executeFetchRequest:request error:&error];
    WCLog(@"%@",users);
    self.users = users;
}

#pragma mark 加载好友数据方法2
- (void)loadUesr2{
    //显示好友数据 保存XMPPRoster.sqlite文件
    //1.上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2.Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //过滤
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@",@"none"];
    request.predicate = pre;
    
    
    //3.执行请求 加载好友
    _resultContr = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *error = nil;
    [_resultContr performFetch:&error];
}

#pragma mark - 结果控制器代理
#pragma mark 数据库内容改变
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   // return self.users.count;
    
    return _resultContr.fetchedObjects.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPJID *friendJid = [_resultContr.fetchedObjects[indexPath.row] jid];
    
    //进入聊天控制器
    [self performSegueWithIdentifier:@"toChatVcSegue" sender:friendJid];
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[WCChatViewController class]]) {
        WCChatViewController *chatVc = destVc;
        chatVc.friendJid = sender;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //获取对应的好友
    //实体类
    //XMPPUserCoreDataStorageObject *user = self.users[indexPath.row];
    XMPPUserCoreDataStorageObject *user = _resultContr.fetchedObjects[indexPath.row];
    
    cell.textLabel.text = user.displayName;
    
#pragma mark 设置监听
    [user addObserver:self forKeyPath:@"sectionNum" options:NSKeyValueObservingOptionNew context:nil];
    
    //标识用户是否在线
    // user.sectionNum  0：在线  1：离开  2：离线
    switch ([user.sectionNum integerValue]) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            
            break;
            
        default:
            cell.detailTextLabel.text = @"见鬼了";
            break;
    }
    //显示好友头像
    if (user.photo) { //默认情况不是程序一启动就有图像
        cell.imageView.image = user.photo;
    }else{
        // 从服务器获取头像
        NSData *imgData = [[WCXMPPTool sharedWCXMPPTool].avatar photoDataForJID:user.jid];
        cell.imageView.image = [UIImage imageWithData:imgData];
    }
    
    return cell;
}



#pragma mark 监听的方法 状态改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    [self.tableView reloadData];
    
}




#pragma mark - 代理 实现delete按钮
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取好友
     XMPPUserCoreDataStorageObject *user = _resultContr.fetchedObjects[indexPath.row];
    
    //删除好友
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [[WCXMPPTool sharedWCXMPPTool].roster removeUser:user.jid];
       
        
    }
    
        
    
    
}

@end



























