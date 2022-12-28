//
//  EMMsgBubbleView.h
//  EaseIM
//
//  Created by lixiaoming on 2021/3/19.
//  Copyright © 2021 lixiaoming. All rights reserved.
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
NS_ASSUME_NONNULL_BEGIN

@interface EMMsgBubbleView : UIImageView
- (void)setModel:(EaseMessageModel *)model;
@end

NS_ASSUME_NONNULL_END
