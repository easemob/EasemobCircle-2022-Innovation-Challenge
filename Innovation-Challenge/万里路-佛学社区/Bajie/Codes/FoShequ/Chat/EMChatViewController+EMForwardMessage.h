//
//  EMChatViewController+EMForwardMessage.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/11/28.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatViewController.h"
#import "EMAlertController.h"
NS_ASSUME_NONNULL_BEGIN

@interface EMChatViewController (EMForwardMessage)

- (void)forwardMenuItemAction:(EMChatMessage*)message;

@end

NS_ASSUME_NONNULL_END
