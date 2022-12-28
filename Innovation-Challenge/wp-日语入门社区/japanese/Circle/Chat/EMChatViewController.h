//
//  EMChatViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/11/27.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
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
#import "EaseChatViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface EMChatViewController : UIViewController
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EaseChatViewController *chatController;

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(EMConversationType)conType;
//本地通话记录
- (void)insertLocationCallRecord:(NSNotification*)noti;

- (NSArray *)formatMessages:(NSArray<EMChatMessage *> *)aMessages;

@end

NS_ASSUME_NONNULL_END
