//
//  WCXMPPTool.m
//  WeChat
//
//  Created by 倪建 on 16/3/17.
//  Copyright © 2016年 倪建. All rights reserved.
//

#import "WCXMPPTool.h"


@interface WCXMPPTool ()<XMPPStreamDelegate>{
    XMPPStream *_xmppStream; //与服务器交互的核心类
    
    
    
    XMPPvCardAvatarModule *_avatar; //电子名片的头像模块
    
    XMPPRoster *_roster; //花名册
    XMPPRosterCoreDataStorage *_rosterStorage; // 花名册数据存储
    
    
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
/**
 *  释放资源
 */
- (void)teardownStream;

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

#pragma mark - 私有方法=========================
#pragma mark - 实现登录

// 1.初始化XMPPStream
- (void)setupStream{
    // 创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc]init];
    
#pragma mark 添加xmpp模块
  #pragma mark   1. 添加电子名片模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc]initWithvCardStorage:_vCardStorage];
    //激活
    [_vCard activate:_xmppStream];
    
    
   #pragma mark  2.添加头像模块
    //电子名片模块会配合“头像模块”一起使用
    _avatar = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_vCard];
    [_avatar activate:_xmppStream];
    
    #pragma mark  3.添加'花名册'模块
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    _roster = [[XMPPRoster alloc]initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    
    
    
    
    
#warning 设置代理 -所有的代理方法都在子线程中被调用
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
}

#pragma mark 离开程序 清空资源
- (void)teardownStream{
    //移除代理
    [_xmppStream removeDelegate:self];
    
    //取消模块
    [_avatar deactivate];
    [_vCard deactivate];
    [_roster deactivate];
    
    //断开连接
    [_xmppStream disconnect];
    
    //清空资源
    _xmppStream = nil;
    _vCardStorage = nil;
    _vCard = nil;
    _avatar = nil;
    _roster = nil;
    _rosterStorage = nil;
    
}

#pragma mark 连接服务器（传一个jid）
// 2.连接服务器（传一个jid）
- (void)connectToHost{
    
    if(!_xmppStream){
        [self setupStream];
    }

    XMPPJID *myJid = nil;
    
    WCAccount *account = [WCAccount shareAccount];
    if (self.isRegisterOperation) {
        //注册
        NSString *registerUser = [WCAccount shareAccount].registerUser;
         myJid = [XMPPJID jidWithUser:registerUser domain:account.domain resource:@"iPhone"];
    }else{
        //登录
        // 1. 设置登录用户的jid
        // resource 用户登录客户端设备的类型
        NSString *loginUser = [WCAccount shareAccount].loginUser;
        
        myJid = [XMPPJID jidWithUser:loginUser domain:account.domain resource:@"iPhone"];
    }
    
    
    
    _xmppStream.myJID = myJid;
    
    
    // 2. 设置主机地址
    _xmppStream.hostName = account.host;
    
    // 3. 设置主机端口号  默认就是5222，可以不用设置
    _xmppStream.hostPort = account.port;
    
    // 4. 发送连接
    NSError *error = nil;
    //缺少必要的参数时就会连接失败  ？没有设置jid
    // XMPPStreamTimeoutNone =1 不超时
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        WCLog(@"%@",error);
    }else{
        WCLog(@"发起连接成功");
    }
    
}

#pragma 连接成功后发送密码
// 3.连接成功后发送密码
- (void)sendPassWordToHost{
    NSError *error = nil;
    
    NSString *loginPwd = [WCAccount shareAccount].loginPwd;
    
    [_xmppStream authenticateWithPassword:loginPwd error:&error];
    if (error) {
        WCLog(@"%@",error);
    }
}

#pragma mark 发送在线指令
// 4. 发送一个“在线消息”给服务器-->可以通知其他用户你在线
- (void)sendOnLine{
    //XMPP框架已经把所有的指令封装成对象
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
    WCLog(@"发送在线指令");
}

#pragma mark 发送离线指令
- (void)sendOffLine{
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
     WCLog(@"发送离线指令");
}

#pragma mark 与服务器断开连接
- (void)disconnetFromeHost{
    
    [_xmppStream disconnect];
}

#pragma mark - 私有方法 end ===============

//**********************************************************

#pragma mark - XMPPStreamDelegate   代理方法 begin
#pragma mark 连接建立成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    WCLog(@"连接成功");
    if (self.isRegisterOperation) {
        //注册
        
        NSString *registerPwd = [WCAccount shareAccount].registerPwd;
        NSError *error = nil;
        
        // 连接成功 发送注册请求密码！！！
        
        [_xmppStream registerWithPassword:registerPwd error:&error];
        if (error) {
            WCLog(@"%@",error);
        }
        
    }else{
        //登录
        
        //连接服务器成功后发送密码
        [self sendPassWordToHost];
    }
 
}

#pragma mark 与服务器断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    WCLog(@"断开连接");
  
}

#pragma mark 登录成功
//Authenticate 认证
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    WCLog(@"登录成功");
    [self sendOnLine];
    
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultLoginSucess);
    }
}

#pragma mark 登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    WCLog(@"%s   %@",__func__,error);
    
    //回调resultBlock
    if (_resultBlock) {
        //回调resultBlock块方法
        _resultBlock(XMPPResultLoginFailure);
    }
}

#pragma mark 注册成功

-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    if(_resultBlock){
        _resultBlock(XMPPResultRegisterSucess);
    }
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    if(_resultBlock){
        _resultBlock(XMPPResultRegisterFailure);
    }
   
}


#pragma mark - XMPPStreamDelegate   代理方法 end


#pragma mark - 公共方法=======================
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
    //请求连接之前先除去已连的连接
    [_xmppStream disconnect];
    
    //保存 传过来的 “块方法”
    _resultBlock = resultBlock;
    
    //注册
    
    // 1.发送“注册的jid”给服务器，请求一个长连接
    [self connectToHost];
    
    // 2.连接成功，发送密码
    
    
}

#pragma mark - 公共方法 end ================
- (void)dealloc{
    [self teardownStream];
}
@end













