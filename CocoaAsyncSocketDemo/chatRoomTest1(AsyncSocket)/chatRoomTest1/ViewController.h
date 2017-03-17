//
//  ViewController.h
//  chatRoomTest1
//
//  Created by mac on 16/5/4.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstant;
@property (weak, nonatomic) IBOutlet UITextView *textView1;
@property (weak, nonatomic) IBOutlet UITableView *tableView1;

- (IBAction)sendMassageBtuClick:(UIButton *)sender;

@end

