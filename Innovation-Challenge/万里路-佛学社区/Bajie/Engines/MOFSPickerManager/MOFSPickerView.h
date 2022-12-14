//
//  MOFSPickerView.h
//  MOFSPickerManager
//
//  Created by lzqhoh@163.com on 16/8/30.
//  Copyright © 2019年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolbar.h"

@interface MOFSPickerView : UIPickerView

@property (nonatomic, assign) NSInteger showTag;
@property (nonatomic, strong) MOFSToolbar *toolBar;
@property (nonatomic, strong) UIView *containerView;

- (void)showMOFSPickerViewWithDataArray:(NSArray *)array commitBlock:(void(^)(NSString *string))commitBlock cancelBlock:(void(^)())cancelBlock;

@end
