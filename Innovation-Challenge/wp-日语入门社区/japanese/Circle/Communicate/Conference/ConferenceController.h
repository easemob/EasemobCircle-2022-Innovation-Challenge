//
//  ConferenceController.h
//  EMiOS_IM
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfInviteUsersViewController.h"
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
#import "EaseMessageModel.h"
#import "EMDemoOptions.h"
@class EMConferenceViewController;
@interface ConferenceController : NSObject

+ (instancetype)sharedManager;

//开始一场会议（群组/聊天室）
- (void)communicateConference:(EMConversation *)conversation rootController:(UIViewController *)controller;

@end

