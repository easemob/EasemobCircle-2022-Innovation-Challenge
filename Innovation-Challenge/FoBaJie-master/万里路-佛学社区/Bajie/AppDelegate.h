//
//  AppDelegate.h
//  Xuefoqifu
//
//  Created by MingmingSun on 16/7/17.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KGModal.h>
#import <SoundManager.h>
#import "LocalItem.h"
#import "UserInfoItem.h"
#import <LKDBHelper.h>

typedef enum {
	EStoreNotReached = 0,
	EStoreCanPay,
	EStoreCanNotPay,
	EStoreReachFailed,
}EReachedTag;

//static NSString * const kIAPXY_8 = @"fxuyuan_0";
//static NSString * const kIAPXY_18 = @"fxuyuan_2";
//static NSString * const kIAPXY_50 = @"fxuyuan_3";
//static NSString * const kIAPXY_88 = @"fxuyuan_4";
//static NSString * const kIAPXY_138 = @"fxuyuan_5";
//static NSString * const kIAPXY_198 = @"fxuyuan_6";
//static NSString * const kIAPXY_268 = @"fxuyuan_7";
//static NSString * const kIAPXY_588 = @"fxuyuan_8";
//
//static NSString * const kIAPFN_1 = @"fofeng_1";
//static NSString * const kIAPFN_8 = @"fofeng_2";
//static NSString * const kIAPFN_50 = @"fofeng_3";
//static NSString * const kIAPFN_98 = @"fofeng_4";
//static NSString * const kIAPFN_298 = @"fofeng_5";
//
//static NSString * const kIAPXH_8 = @"fxiang_1";
//static NSString * const kIAPXH_98 = @"fxiang_2";
//static NSString * const kIAPXH_198 = @"fxiang_3";
//
//@protocol VCIAPDelegate<NSObject>
//@optional
//- (void)VCIAPSucceed:(NSString*)aSucc;
//- (void)VCIAPFailed:(NSString*)aSucc;
//@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) NSArray *availableProducts;
@property (nonatomic, strong) NSString *myNowAppId;
@property (nonatomic, assign) int storePayStatus;

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong) KGModal *myKGModal;
@property(nonatomic,strong) SoundManager *mySoundManager;

@property(strong,nonatomic) LKDBHelper* globalDBManager;
@property(strong,nonatomic) UserInfoItem *myUserItem;
@property(strong,nonatomic) LocalItem *myLocalItem;

@property(nonatomic,assign) id myIAPDelegate;
-(void)startToIAP:(NSString*)aIAP;

@end

