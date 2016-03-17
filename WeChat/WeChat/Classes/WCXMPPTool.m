//
//  WCXMPPTool.m
//  WeChat
//
//  Created by 倪建 on 16/3/17.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCXMPPTool.h"
#import "XMPPFramework.h"

@interface WCXMPPTool ()<XMPPStreamDelegate>{
    XMPPStream *_xmppStream; //与服务器交互的核心类
    
    XMPPResultBlock _resultBlock; //结果回调Block
}



/** 用户登录流程
 =====私有方法=====
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

// 发送离线消息
- (void)sendOffLine;

// 与服务器断开连接
- (void)disconnetFromeHost;


@end


@implementation WCXMPPTool

singleton_implementation(WCXMPPTool)

#pragma mark -私有方法=========================
#pragma mark 实现登录

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
    
    XMPPJID *myJid = [XMPPJID jidWithUser:user domain:@"nijiandemacbook-air.local" resource:@"iPhone"];
    _xmppStream.myJID = myJid;
    
    
    // 2. 设置主机地址
    _xmppStream.hostName = @"127.0.0.1";
    
    // 3. 设置主机端口号  默认就是5222，可以不用设置
    _xmppStream.hostPort = 5222;
    
    // 4. 发送连接
    NSError *error = nil;
    //缺少必要的参数时就会连接失败  ？没有设置jid
    // XMPPStreamTimeoutNone =1 不超时
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

#pragma mark 发送离线消息
- (void)sendOffLine{
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
}

#pragma mark 与服务器断开连接
- (void)disconnetFromeHost{
    
    [_xmppStream disconnect];
    
}

#pragma mark -私有方法 end ===============

//**********************************************************

#pragma mark -XMPPStreamDelegate   代理方法 begin
#pragma mark 连接建立成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"%s",__func__);
    //连接服务器成功后发送密码
    [self sendPassWordToHost];
}

#pragma mark 与服务器断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    NSLog(@"%s",__func__);
    
    
    
}

#pragma mark 登录成功
//Authenticate 认证
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
        //回调resultBlock块方法
        _resultBlock(XMPPResultLoginFailure);
    }
}
#pragma mark -XMPPStreamDelegate   代理方法 end


#pragma mark -公共方法=======================
#pragma mark 用户登录
- (void)xmppLogin:(XMPPResultBlock)resultBlock{
    //不管什么情况，先断开以前的连接
    [_xmppStream disconnect];
    
    //保存resulBlock
    //将方法通过块 传递过来  。这边可以通过调用块，来调用这个方法
    _resultBlock = resultBlock;
    
    //连接服务器开始登录操作
    [self connectToHost];
}

#pragma mark 用户注销
- (void)xmppLogout{
    //注销
    // 1.发送“离线消息”给服务器
    [self sendOffLine];
    
    // 2.断开与服务器连接
    [self disconnetFromeHost];
}


#pragma mark 用户注册
- (void)xmppRegister:(XMPPResultBlock)resultBlock{
    //注册
    
    // 1.发送“注册的jid”给服务器，请求一个长连接
    
    
    // 2.连接成功，发送密码
    
    
}

#pragma mark -公共方法 end ================
@end













