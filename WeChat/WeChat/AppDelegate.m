//
//  AppDelegate.m
//  WeChat
//
//  Created by 倪建 on 16/2/14.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPFramework.h"

@interface AppDelegate ()<XMPPStreamDelegate>{
    XMPPStream *_xmppStream; //与服务器交互的核心类
    
    XMPPResultBlock _resultBlock; //结果回调Block
}



/** 用户登录流程
1. 初始化XMPPStream
2. 连接服务器（传一个jid）
3. 连接成功，之后发送密码
 //默认的登录成功是不在线的
4. 发送一个“在线消息”给服务器-->可以通知其他用户你在线
**/

// 1.初始化XMPPStream
- (void)setupStream;

// 2.连接服务器（传一个jid）
- (void)connectToHost;

// 3.连接成功后发送密码
- (void)sendPassWordToHost;

// 4. 发送一个“在线消息”给服务器-->可以通知其他用户你在线
- (void)sendOnLine;



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self setupStream];
//    [self connectToHost];
    
    //判断用户是否登陆
    
    if([WCAccount shareAccount].isLogin){
        // 回到主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // 1. 获取Main.storyboard的第一个根控制器
            id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
            
            // 2. 切换window的根控制器
            [UIApplication sharedApplication].keyWindow.rootViewController = vc;
            
        });
        
    }
    
    return YES;
}

#pragma mark -私有方法
// 1.初始化XMPPStream
- (void)setupStream{
    // 创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc]init];
    
#warning 设置代理 -所有的代理方法都在子线程中被调用

    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
}

// 2.连接服务器（传一个jid）
- (void)connectToHost{
    if(!_xmppStream){
        [self setupStream];
    }
    
    // 1. 设置登录用户的jid
    // resource 用户登录客户端设备的类型
    //NSString *user = [[NSUserDefaults standardUserDefaults]objectForKey:@"user"];
    NSString *user = [WCAccount shareAccount].user;
    
    XMPPJID *myJid = [XMPPJID jidWithUser:user domain:@"nijiandemacbook-air.local" resource:@"iPhone6"];
    _xmppStream.myJID = myJid;
    
    
    // 2. 设置主机地址
    _xmppStream.hostName = @"127.0.0.1";
    
    // 3. 设置主机端口号  默认就是5222，可以不用设置
    _xmppStream.hostPort = 5222;
    
    // 4. 发送连接
    NSError *error = nil;
    //缺少必要的参数时就会连接失败  ？没有设置jid
    
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"%@",error);
    }else{
        NSLog(@"发起连接成功");
    }
    
}

// 3.连接成功后发送密码
- (void)sendPassWordToHost{
    NSError *error = nil;
    //NSString *pwd = [[NSUserDefaults standardUserDefaults]objectForKey:@"pwd"];
    NSString *pwd = [WCAccount shareAccount].pwd;
    
    [_xmppStream authenticateWithPassword:pwd error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

// 4. 发送一个“在线消息”给服务器-->可以通知其他用户你在线
- (void)sendOnLine{
    //XMPP框架已经把所有的指令封装成对象
    XMPPPresence *presence = [XMPPPresence presence];
    NSLog(@"%@",presence);
    [_xmppStream sendElement:presence];
}


#pragma mark -XMPPStreamDelegate   代理方法
#pragma mark 连接建立成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"%s",__func__);
    [self sendPassWordToHost];
}

#pragma mark 登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"%s",__func__);
    [self sendOnLine];
    
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultLoginSucess);
    }
}

#pragma mark 登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"%s   %@",__func__,error);
    
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultLoginFailure);
    }
}


#pragma mark -公共方法
#pragma mark 用户登录
- (void)xmppLogin:(XMPPResultBlock)resultBlock{
    //不管什么情况，先断开以前的连接
    [_xmppStream disconnect];
    
    //保存resulBlock
    _resultBlock = resultBlock;
    
    
    //连接服务器开始登录操作
    [self connectToHost];
}


@end
