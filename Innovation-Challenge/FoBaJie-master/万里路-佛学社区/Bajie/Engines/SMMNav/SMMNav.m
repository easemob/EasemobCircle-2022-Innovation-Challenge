//
//  SMMNav.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/9/9.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "SMMNav.h"
#import <FlatUIKit.h>
#import "AppDelegate.h"

@implementation SMMNav

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.navigationBar configureFlatNavigationBarWithColor:MMColorOrange];
        self.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationBar.tintColor = [UIColor whiteColor];
//        self.navigationItem.backBarButtonItem = [UIBarButtonItem alloc i]
        return self;
    }
    return self;
}

@end
