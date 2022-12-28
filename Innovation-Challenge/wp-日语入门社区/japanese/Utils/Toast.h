//
// Created by LYQ on 16/7/30.
// Copyright (c) 2020 LYQ. All rights reserved.
//

#import <UIKit/UIKit.h>


#define TOAST_LENGTH_SHORT 1.3;
#define CURRENT_TOAST_TAG 6984678
@interface Toast : NSObject

+(void)show:(NSString *)message;
@property (nonatomic, retain)NSString *message;
@property (nonatomic, retain)UIView *contentView;
@property (nonatomic, retain)UILabel *label;
@property (nonatomic)CGFloat duration;

@end
