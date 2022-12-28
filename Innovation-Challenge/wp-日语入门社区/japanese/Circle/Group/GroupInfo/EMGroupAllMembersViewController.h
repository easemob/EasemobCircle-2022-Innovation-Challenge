//
//  EMGroupAllMembersViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/12/5.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"
#import "UIViewController+Util.h"
#import "UIViewController+HUD.h"
#import <Masonry.h>
#import "EMDefines.h"
#import "EMColorDefine.h"
#import "EaseCallDefine.h"
#import "EaseIMKitManager.h"
#import <HyphenateChat/HyphenateChat.h>
NS_ASSUME_NONNULL_BEGIN

@interface EMGroupAllMembersViewController : EMRefreshViewController
- (instancetype)initWithGroup:(EMGroup *)aGroup;
@end

NS_ASSUME_NONNULL_END
