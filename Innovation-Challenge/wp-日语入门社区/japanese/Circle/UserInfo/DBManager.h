//
//  DBManager.h
//  EaseIM
//
//  Created by lixiaoming on 2021/3/29.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewController+Util.h"
#import "UIViewController+HUD.h"
#import <Masonry.h>
#import "EMDefines.h"
#import "EMColorDefine.h"
#import "EaseCallDefine.h"
#import "EaseIMKitManager.h"
#import <HyphenateChat/HyphenateChat.h>
#import "EMAlertController.h"
#import "EMAlertView.h"
NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject
+(instancetype _Nonnull ) alloc __attribute__((unavailable("call sharedInstance instead")));
+(instancetype _Nonnull ) new __attribute__((unavailable("call sharedInstance instead")));
-(instancetype _Nonnull ) copy __attribute__((unavailable("call sharedInstance instead")));
-(instancetype _Nonnull ) mutableCopy __attribute__((unavailable("call sharedInstance instead")));
+(instancetype) sharedInstance;
-(void) addUserInfos:(NSArray<EMUserInfo*>*)aUserInfos;
-(NSArray<EMUserInfo*>*) loadUserInfos;
@end

NS_ASSUME_NONNULL_END
