//
//  MOFSAddressPickerView.h
//  MOFSPickerManager
//
//  Created by lzqhoh@163.com on 16/8/31.
//  Copyright © 2019年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolbar.h"
#import "HZLocation.h"

@interface MOFSAddressPickerView : UIPickerView

@property (nonatomic, assign) NSInteger showTag;
@property (nonatomic, strong) MOFSToolbar *toolBar;
@property (nonatomic, strong) UIView *containerView;
@property (strong, nonatomic) HZLocation *locate;

- (void)showMOFSAddressPickerCommitBlock:(void(^)(NSString *address, NSString *zipcode))commitBlock cancelBlock:(void(^)())cancelBlock;

@end
