//
//  MOFSAddressPickerView.h
//  MOFSPickerManager
//
//  Created by lzqhoh@163.com on 16/8/31.
//  Copyright © 2019年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolbar.h"

@interface MOFSWishTypePickerView : UIPickerView

@property (nonatomic, assign) NSInteger showTag;
@property (nonatomic, strong) MOFSToolbar *toolBar;
@property (nonatomic, strong) UIView *containerView;
@property (strong, nonatomic) NSArray *bigType;
@property (nonatomic, strong) NSArray *smallType;

- (void)showMOFSWishTypePickerCommitBlock:(void(^)(NSString *type1, NSString *type2))commitBlock cancelBlock:(void(^)())cancelBlock;

@end

