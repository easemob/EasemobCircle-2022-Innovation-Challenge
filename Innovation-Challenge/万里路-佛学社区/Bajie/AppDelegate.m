//
//  AppDelegate.m
//  BabyBluetoothAppDemo
//
//  Created by LYQ on 22/8/1.
//  Copyright (c) 2019年 LYQ. All rights reserved.
//

#import "AppDelegate.h"
#import "SMMNav.h"
#import "RootViewController.h"
#import <SVProgressHUD.h>
#import <JPUSHService.h>
#import <BmobSDK/Bmob.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import <AdSupport/AdSupport.h>
#import <Security/Security.h>
//#import "EaseIMHelper.h"
#import "UUID.h"
//@import
static BmobObject *allOBJ;
@interface AppDelegate ()

@property(nonatomic,assign) BOOL enableIAP;

@end
@import GoogleMobileAds;
@import HyphenateChat;
@implementation AppDelegate

@synthesize myNowAppId;
@synthesize storePayStatus;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	

    [Bmob registerWithAppKey:@"fdb0f295c95cf7ae1f738b020924ad98"];
    EMOptions *options = [EMOptions optionsWithAppkey:@"1149221111120747#yulao"];
        options.apnsCertName = nil;
        [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    
    //初始化
//    NSUserDefaults *tempD = [NSUserDefaults standardUserDefaults];
//    [tempD removeObjectForKey:@"username"];
//    [tempD removeObjectForKey:@"password"];
//    [tempD synchronize];
    
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    NSString *idfv = [UUID getUUID];
    NSString *idfv = [UUID getUUID];
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"AppInfo"];
    
    [bquery whereKey:@"UNIC" equalTo:idfv];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if(array.count == 0){
            BmobObject *gameScore = [BmobObject objectWithClassName:@"AppInfo"];
            [gameScore setObject:idfv forKey:@"UNIC"];
            int num = (arc4random() % 1000000);
            NSString *randomNumber = [NSString stringWithFormat:@"%.6d", num];
            [gameScore setObject:[NSString stringWithFormat:@"功德人%@",randomNumber] forKey:@"NickName"];
            [gameScore setObject:[NSNumber numberWithInteger:15] forKey:@"GongDeCounts"];
            [gameScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                //进行操作
                if(isSuccessful){
                    NSLog(@"自动成功");
//                    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"新活动" message:@"为回馈您的支持，用户每日可免费烧香获取并积攒功德值，功德值足够情况下可以免费兑换任何兑换经书或礼品。" preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction *b = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        
//                    }];
//                    [a addAction:b];
                    
                }else{
                    NSLog(@"-------%@",error.description);
                }
                
            }];
        }
    for (BmobObject *obj in array) {
    //打印playerName
//                allOBJ = obj;
                NSLog(@"数据加载成功");
    }
    }];
//    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
	// Override point for customization after application launch.
//	NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
//
//	JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
//    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
//
//    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
//
//    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//
//    [JPUSHService setupWithOption:launchOptions appKey:@"82cbc8b73a5a7ac2f120f6ce"
//                          channel:@"XuefoQifu"
//                 apsForProduction:true
//            advertisingIdentifier:advertisingId];
//	self.storePayStatus = EStoreNotReached;
//	self.myNowAppId = kIAPXY_8;
////	self.iapManager = [[DNSInAppPurchaseManager alloc] init];
////	self.iapManager.delegate = self;
//	[self setupStore];
	
	[SVProgressHUD setMinimumDismissTimeInterval:2.0f];
	
	self.myKGModal = [KGModal sharedInstance];
	[self.myKGModal setTapOutsideToDismiss:YES];
	[self.myKGModal setCloseButtonType:KGModalCloseButtonTypeRight];
	[self.myKGModal setModalBackgroundColor:[UIColor clearColor]];
	
	self.globalDBManager = [LKDBHelper getUsingLKDBHelper];
	//[self.globalDBManager dropAllTable];//清空数据库
    self.myUserItem = [UserInfoItem searchSingleWithWhere:nil orderBy:nil];
    if(!self.myUserItem)
    {
        self.myUserItem = [[UserInfoItem alloc] init];
        [self.myUserItem saveToDB];
    }
	self.myLocalItem = [LocalItem searchSingleWithWhere:nil orderBy:nil];
	if(!self.myLocalItem)
	{
		self.myLocalItem = [[LocalItem alloc] init];
		[self.myLocalItem saveToDB];
	}
	
	RootViewController *vc = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
        vc.view.backgroundColor = UIColor.whiteColor;
	vc.edgesForExtendedLayout = UIRectEdgeNone;
	
	SMMNav *nav = [[SMMNav alloc] initWithRootViewController:vc];
        nav.view.backgroundColor = UIColor.whiteColor;
    nav.navigationBar.translucent = NO;
	//    DesktopInfo
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = nav;
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
//    [JPUSHService registerDeviceToken:deviceToken];
}

-(void)setupStore
{
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"applicationWillResignActive");
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"applicationWillEnterForeground");
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

-(void)startToIAP:(NSString*)aIAP{
	
}



@end
