//
//  UIImageView+UserInfo.h
//  EaseIM
//
//  Created by lixiaoming on 2021/3/31.
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
NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (UserInfo)
-(void)showUserInfoAvatar:(NSString*)aUid;
@end

NS_ASSUME_NONNULL_END
