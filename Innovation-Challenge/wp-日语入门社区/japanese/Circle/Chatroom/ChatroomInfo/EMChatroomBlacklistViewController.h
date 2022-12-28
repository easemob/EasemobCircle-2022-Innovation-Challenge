//
//  EMChatroomBlacklistViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshTableViewController.h"
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
NS_ASSUME_NONNULL_BEGIN

@interface EMChatroomBlacklistViewController : EMRefreshTableViewController

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom;

@end

NS_ASSUME_NONNULL_END
