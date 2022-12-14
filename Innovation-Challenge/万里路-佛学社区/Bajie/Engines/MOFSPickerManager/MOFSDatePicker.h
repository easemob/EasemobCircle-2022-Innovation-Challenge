//
//  MOFSDatePicker.h
//  MOFSPickerManager
//
//  Created by lzqhoh@163.com on 16/8/26.
//  Copyright © 2019年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolbar.h"

typedef void (^CommitBlock)(NSDate *date);
typedef void (^CancelBlock)();

@interface MOFSDatePicker : UIDatePicker

@property (nonatomic, strong) MOFSToolbar *toolBar;
@property (nonatomic, strong) UIView *containerView;

- (void)showMOFSDatePickerViewWithTag:(NSInteger)tag firstDate:(NSDate *)date commit:(CommitBlock)commitBlock cancel:(CancelBlock)cancelBlock;

@end
