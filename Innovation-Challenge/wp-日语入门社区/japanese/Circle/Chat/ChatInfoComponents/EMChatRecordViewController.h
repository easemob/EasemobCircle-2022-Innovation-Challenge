//
//  EMChatRecordViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/15.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSearchViewController.h"
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
NS_ASSUME_NONNULL_BEGIN

@interface EMChatRecordViewController : EMSearchViewController

- (instancetype)initWithCoversationModel:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
