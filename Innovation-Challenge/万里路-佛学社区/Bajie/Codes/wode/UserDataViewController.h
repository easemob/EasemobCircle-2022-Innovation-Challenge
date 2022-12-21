//
//  UserDataViewController.h
//  Xuefoqifu
//
//  Created by MingmingSun on 16/9/27.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WodeViewController.h"
#import <BmobSDK/Bmob.h>
@interface UserDataViewController : UITableViewController

@property(nonatomic,weak) WodeViewController *myDelegate;
@property(nonatomic,weak) BmobObject *mainObj;

@end
