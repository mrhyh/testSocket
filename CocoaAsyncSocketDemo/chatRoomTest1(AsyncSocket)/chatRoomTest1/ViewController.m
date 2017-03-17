//
//  ViewController.m
//  chatRoomTest1
//
//  Created by mac on 16/5/4.
//  Copyright © 2016年 mac. All rights reserved.
//  masksToBounds 是否允许切割子视图
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
@interface ViewController ()<GCDAsyncSocketDelegate>
{
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    NSMutableArray *_msgArray;
    GCDAsyncSocket *_socket;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 监听键盘将要显示的动作
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // 监听键盘将要消失的动作
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _msgArray = [[NSMutableArray alloc]init];
    [_tableView1 setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark connected 按钮
- (IBAction)connection:(UIBarButtonItem *)sender {
    
    NSString *host = @"127.0.0.1";
    UInt32 port = 54321;
    
    //创建GCDAsyncSocket
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [_socket connectToHost:host onPort:port error:&error];
    if (error != nil) {
        NSLog(@"%@",error);
    }
}

#pragma mark socket delegate
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"%s",__func__);
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"%@",err);
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s",__func__);
    [_socket readDataWithTimeout:-1 tag:tag];
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"%s",__func__);
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receiverStr);
    if (tag == 101) {//登陆指令
        
    }else if(tag == 102){//消息指令
        [_msgArray addObject:receiverStr];
        //刷新是会延迟  因为代理是在子线程调用的
        [_tableView1 reloadData];
    }
    
}

#pragma mark login 按钮
- (IBAction)login:(UIBarButtonItem *)sender {
    
    NSString *msg = @"iam:jing";
    
    //写
    [_socket writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:101];

    
    
}

#pragma mark 读取数据
-(void)readData{
    uint8_t buff[1024];
    
    int len = [_inputStream read:buff maxLength:sizeof(buff)];
    NSMutableData *input = [[NSMutableData alloc] init];
    [input appendBytes:buff length:len];
    NSString *resultstring = [[NSString alloc]initWithData:input encoding:NSUTF8StringEncoding];
    NSLog(@"%@",resultstring);
    [_msgArray addObject:resultstring];
    [_tableView1 reloadData];
    
}
#pragma mark 键盘显示keyboardWillShow
-(void)keyboardWillShow:(NSNotification *)noti{
    //获取用户信息
    NSDictionary *info = [noti userInfo];
    //获取键盘的frame
    NSValue *value = info[UIKeyboardFrameBeginUserInfoKey];
    //获取键盘的高度
    CGFloat height = [value CGRectValue].size.height;
    //设置view的约束
    _bottomConstant.constant = height;
    //获取键盘动画时间
    NSTimeInterval time ;
    NSNumber *timeDur = info[UIKeyboardAnimationDurationUserInfoKey];
    [timeDur getValue:&time];
    //设置动画
    [UIView animateWithDuration:time animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark 键盘消失keyboardWillHide
-(void)keyboardWillHide:(NSNotification *)noti{
    //获取用户信息
    NSDictionary *info = [noti userInfo];
    //设置view的约束
    _bottomConstant.constant = 0;
    //获取键盘动画时间
    NSTimeInterval time ;
    NSNumber *timeDur = info[UIKeyboardAnimationDurationUserInfoKey];
    [timeDur getValue:&time];
    //设置动画
    [UIView animateWithDuration:time animations:^{
        [self.view layoutIfNeeded];
    }];

}

#pragma mark 滑动tbaleview 退出编辑  因为实现了uitableivew  所以不需要实现scrollerviwe的delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark table view Override
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _msgArray.count;
};


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellid = @"msgCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.textLabel.text = _msgArray[indexPath.row];
    }
    return cell;
};

#pragma mark send 按钮
- (IBAction)sendMassageBtuClick:(UIButton *)sender {
    if(_textView1.text.length != 0){
        NSString *msg = [@"msg:" stringByAppendingString:_textView1.text];
        [_socket writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:102];
    }
    [self.view endEditing:YES];
    _textView1.text = @"";
}


#pragma mark 发送的封装方法
-(void)sendMassage:(NSString *)msg{
    NSData *buff = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [_outputStream write:buff.bytes maxLength:buff.length];
}
@end
