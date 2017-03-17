//
//  ViewController.m
//  testSocketRocket
//
//  Created by hyh on 2017/3/17.
//  Copyright © 2017年 hyh. All rights reserved.
//

#import "ViewController.h"
#import "SRWebSocket.h"
#import "GCDAsyncSocket.h"

@interface ViewController () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self Reconnect];
}


- (void)viewDidDisappear:(BOOL)animated{
    // Close WebSocket
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.webSocket = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //Test CocoaAsyncSocket
    NSString *host = @"127.0.0.1";
    int port = 12345;
    //将GCDAsynSocket设置为全局变量
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self  delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];
    
    
    //连接
    NSError *error = nil;
    [socket connectToHost:host onPort:port error:&error];
    
    //white
    [socket writeData:[@"message" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:101];
    //withTimeout: 超时时间 -1  表示不超时
    //tag: 一个标识
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


//初始化
- (void)Reconnect{
    self.webSocket.delegate = nil;
    [self.webSocket close];
    
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://echo.websocket.org"]]];
    self.webSocket.delegate = self;
    
    self.title = @"Opening Connection...";
    
    [self.webSocket open];
}

//代理方法实现
#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"Websocket Connected");
    self.title = @"Connected!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    self.title = @"Connection Failed! (see logs)";
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
//    NSString *str1 = self.replyContent.text;
//    NSString *str2 = [str1 stringByAppendingFormat:@"%@\n",message];
//    self.replyContent.text = str2;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"Closed Reason:%@",reason);
    self.title = @"Connection Closed! (see logs)";
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"%@",reply);
}

#pragma mark - SendButton Response
- (IBAction)sendAction:(id)sender {
    [self.view endEditing:YES];
    // WebSocket
    if (self.webSocket) {
        [self.webSocket send:@"test success"];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
