//
//  EMAvatarNameModel.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/8/19.
//  Copyright © 2020 娜塔莎. All rights reserved.
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

@interface EMAvatarNameModel : NSObject

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImage *avatarImg;

@property (nonatomic, strong) NSString *from;

@property (nonatomic, strong) NSAttributedString *detail;

@property (nonatomic, strong) NSString *timestamp;

- (instancetype)initWithInfo:(NSString *)keyWord img:(UIImage *)img msg:(EMChatMessage *)msg time:(NSString *)timestamp;

@end

NS_ASSUME_NONNULL_END
