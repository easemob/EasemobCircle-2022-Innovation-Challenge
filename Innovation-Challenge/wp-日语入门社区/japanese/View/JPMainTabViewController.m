//
//  JPMainTabViewController.m
//  japanese
//
//  Created by LYQ on 2021/31.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "JPMainTabViewController.h"
#import "SoundViewController.h"
#import "JPCheckViewController.h"
#import "JPSettingViewController.h"
#import "SQViewController.h"
#import "JPUtils.h"

@implementation JPMainTabViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
//    self.tabBar.backgroundColor = [UIColor blackColor];
    self.tabBar.tintColor = [JPUtils getUIColorByString:@"#57cadb"];
    [self setUpAllChildVC];
    self.tabBar.translucent = NO;
}

-(void)setUpAllChildVC{
    
    JPCheckViewController *newsViewController = [[JPCheckViewController alloc] init];
    [self addOneVC:newsViewController normalImage:[UIImage imageNamed:@"check"] selectImage:[UIImage imageNamed:@"check"] title:@"测一测"];
    
    SoundViewController *reportViewController = [[SoundViewController alloc] init];
    [self addOneVC:reportViewController normalImage:[UIImage imageNamed:@"sound"] selectImage:[UIImage imageNamed:@"sound"] title:@"五十音图"];

    SQViewController *sqViewcontroller = [[SQViewController alloc] init];
    [self addOneVC:sqViewcontroller normalImage:[UIImage imageNamed:@"setting"] selectImage:[UIImage imageNamed:@"setting"] title:@"社区"];

    JPSettingViewController *meViewcontroller = [[JPSettingViewController alloc] init];
    [self addOneVC:meViewcontroller normalImage:[UIImage imageNamed:@"setting"] selectImage:[UIImage imageNamed:@"setting"] title:@"设置"];

    self.selectedIndex = 1;
}
-(void)addOneVC:(UIViewController *)controller normalImage:(UIImage *)normalImage selectImage:(UIImage *)selectImage title:(NSString *)title{
    UINavigationController *baseNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.tabBarItem.image = normalImage;
    controller.tabBarItem.selectedImage = selectImage;
    controller.tabBarItem.title = title;
    [self addChildViewController:baseNavigationController];
}
@end
