//
//  EMGroupSharedFilesViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
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
#import "EMDemoOptions.h"
@interface EMGroupSharedFilesViewController : EMRefreshTableViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end
