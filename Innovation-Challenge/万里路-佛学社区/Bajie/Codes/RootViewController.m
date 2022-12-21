//
//  RootViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/8/20.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "RootViewController.h"
#import "WodeViewController.h"
#import "HuanyuanViewController.h"
#import "ShangxiangViewController.h"
#import "AFSoundManager.h"
#import "AppDelegate.h"
#import <FlatUIKit.h>
#import "FoJIngMenuViewController.h"
#import "GongDeBangViewController.h"
#import "FoShequ/FoSheQuViewController.h"
@interface RootViewController ()

@property(nonatomic,assign) int musicIndex;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
//		self.edgesForExtendedLayout = UIRectEdgeNone;
		//b.创建子控制器
        
        
		ShangxiangViewController *c1=[ShangxiangViewController new];
		c1.tabBarItem.title=@"礼佛堂";
		c1.tabBarItem.tag = 2;
		c1.tabBarItem.image=[UIImage imageNamed:@"tab1"];
        
        FoJIngMenuViewController *c3= [FoJIngMenuViewController new];
        c3.tabBarItem.title = @"藏经阁";
        c3.tabBarItem.tag = 1;
        c3.tabBarItem.image=[UIImage imageNamed:@"tab5"];
		
		HuanyuanViewController *c4=[HuanyuanViewController new];
		c4.tabBarItem.title=@"祈福处";
		c4.tabBarItem.tag = 3;
		c4.tabBarItem.image=[UIImage imageNamed:@"tab4"];
        
        FoSheQuViewController *c5=[FoSheQuViewController new];
        c5.tabBarItem.title=@"佛社区";
        c5.tabBarItem.tag = 4;
        c5.tabBarItem.image=[UIImage imageNamed:@"tab3"];
		
		WodeViewController *c6=[WodeViewController new];
		c6.tabBarItem.title=@"个人主页";
		c6.tabBarItem.tag = 5;
		c6.tabBarItem.image=[UIImage imageNamed:@"tab6"];
		
		self.viewControllers=@[c3,c1,c5,c4,c6];
		self.selectedIndex = 0;
		self.title = [[[self.viewControllers objectAtIndex:self.selectedIndex] tabBarItem] title];
		self.tabBar.tintColor = MMColorOrange;
        self.tabBar.translucent = NO;
		[self.tabBar configureFlatTabBarWithColor:[UIColor whiteColor] selectedColor:[UIColor whiteColor]];
//		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"音乐:关" style:UIBarButtonItemStylePlain target:self action:@selector(theMusic:)];
		
		self.musicIndex = arc4random() % 5 + 1;
	}
	return self;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
	self.title = item.title;
//    self.navigationItem.leftBarButtonItem = (item.tag == 2)?self.helpButton:nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)theMusic:(id)sender {
	if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"音乐:开"]){
		[self.navigationItem.rightBarButtonItem setTitle:@"音乐:关"];
		[[AFSoundManager sharedManager] stop];
	}else{
		[self.navigationItem.rightBarButtonItem setTitle:@"音乐:开"];
		self.musicIndex = arc4random() % 5 + 1;
		[self playMusic];
	}
}

-(void)playMusic
{
	[[AFSoundManager sharedManager] startPlayingLocalFileWithName:[NSString stringWithFormat:@"bg%d.mp3",self.musicIndex] withCompletionBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
		if (finished){
			//next
			[self nextPressed:nil];
			return;
		}
		if (!error) {
			[self.navigationItem.rightBarButtonItem setTitle:@"音乐:开"];
		} else {
			[self.navigationItem.rightBarButtonItem setTitle:@"播放出错"];
		}
	}];
}

-(void)nextPressed:(id)sender{
	[[AFSoundManager sharedManager] stop];
	self.musicIndex = arc4random() % 5 + 1;
	[self playMusic];
}

-(void)currentPlayingStatusChanged:(AFSoundManagerStatus)status {
	
	switch (status) {
			
		case AFSoundManagerStatusFinished:
			//Playing got finished
			break;
			
		case AFSoundManagerStatusPaused:
			//Playing was paused
			break;
			
		case AFSoundManagerStatusPlaying:
			//Playing got started or resumed
			break;
			
		case AFSoundManagerStatusRestarted:
			//Playing got restarted
			break;
			
		case AFSoundManagerStatusStopped:
			//Playing got stopped
			break;
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	//    [[AFSoundManager sharedManager] stop];
}

-(void)dealloc
{
	[[AFSoundManager sharedManager] stop];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

