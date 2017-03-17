//
//  ChatServer.m
//  SocketServerTest
//
//  Created by mac on 16/5/6.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ChatServer.h"
#import "GCDAsyncSocket.h"




@interface ChatServer()<GCDAsyncSocketDelegate>{
    GCDAsyncSocket *_serverSocket;
    dispatch_queue_t _gloableQ;
}
@property(strong,nonatomic)NSMutableArray *clientSocket;

@end
@implementation ChatServer

-(NSMutableArray *)clientSocket{
    if (_clientSocket == nil) {
        _clientSocket = [NSMutableArray array];
    }
    return _clientSocket;
}

-(instancetype)init{
    if (self = [super init]) {
        _gloableQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        //1创建一个服务端的socket
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_gloableQ];
    }
    return self;
}

#pragma mark 创建服务器
-(void)startConnection{
    
    
    
    //2打开监听端口
    NSError *error = nil;
    [_serverSocket acceptOnPort:54321 error:&error];
    
    if (error == nil) {
        NSLog(@"服务器开启成功");
    }else{
        NSLog(@"服务器开启失败");
    }
    //开启主线程循环
    [[NSRunLoop mainRunLoop] run];
}

#pragma mark 有客户端建立连接  sock 服务端  newSocket 客户端的
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"%s",__func__);
    [self.clientSocket addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:100];
    
}

#pragma mark
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // 把回车和换行字符去掉  \r 回车 \n 换行
    [receiverStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [receiverStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSLog(@"收到消息:%@",receiverStr);
    //判断指令
    if ([receiverStr hasPrefix:@"iam:"]) {
        //获取指令后面的信息
        NSString *user = [receiverStr componentsSeparatedByString:@":"][1];
        
        //响应给客户数据
        NSString *respStr = [user stringByAppendingString:@"has joined"];
        
        [sock writeData:[respStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:101];
    }else if([receiverStr hasPrefix:@"msg:"]){
        //获取指令后面的信息
        NSString *msg = [receiverStr componentsSeparatedByString:@":"][1];
        

        [sock writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:101];
    }else if([receiverStr isEqualToString:@"quit"]){
        [self.clientSocket removeObject:sock];
        [sock disconnect];
    }
    // 在真正的服务器中还有很多其他的业务    消息保存到数据库中 等
    NSLog(@"%s",__func__);
}
@end
