//
//  main.m
//  SocketServerTest
//
//  Created by mac on 16/5/6.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatServer.h"
int main(int argc, const char * argv[]) {
    
    
    
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        ChatServer *server = [[ChatServer alloc]init];
        [server startConnection];
    }
    return 0;
}
