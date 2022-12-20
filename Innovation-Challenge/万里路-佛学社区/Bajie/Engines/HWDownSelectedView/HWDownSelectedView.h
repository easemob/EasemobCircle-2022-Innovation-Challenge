//
//  HWDownSelectedView.h
//  HWDownSelectedTF
//
//  Created by HanWei on 22/12/15.
//  Copyright © 2019年 AndLiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWDownSelectedView;
@protocol HWDownSelectedViewDelegate <NSObject>

@required
- (void)downSelectedView:(HWDownSelectedView *)selectedView didSelectedAtIndex:(NSIndexPath *)indexPath;

@end

@interface HWDownSelectedView : UIView

@property (nonatomic, weak) id <HWDownSelectedViewDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *listArray;

/// 一些控件属性
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy, readonly) NSString *text;

- (void)setText:(NSString *)atext;
- (void)setEnabled:(Boolean)aIsEnable;
- (void)show;
- (void)close;

@end
