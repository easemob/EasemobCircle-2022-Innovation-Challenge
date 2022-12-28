//
//  EMGroupInfoViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMRefreshTableViewController.h"
#import "EMRefreshViewController.h"
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

@interface EMGroupInfoViewController : EMRefreshViewController

@property (nonatomic, copy) void (^leaveOrDestroyCompletion)(void);

- (instancetype)initWithConversation:(EMConversation *)aConversation;

@property (nonatomic, copy) void (^clearRecordCompletion)(BOOL isClearRecord);

@end

NS_ASSUME_NONNULL_END
