//
//  YuanDetailViewController.h
//  Xuefoqifu
//
//  Created by MingmingSun on 2018/2/25.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#define isServiceVerify  1//支付完成返回 校验方式
@protocol ydDelegate <NSObject>

- (void)ydClickIndex:(NSInteger)buttonIndex;

@end

@interface YuanDetailViewController : UIViewController

@property(nonatomic,assign) id<ydDelegate> delegate;
@property(nonatomic,strong) NSDictionary *myWish;
@property(nonatomic,assign) NSInteger numArray;
@property (nonatomic, strong) UIButton *completBtn;

@property(nonatomic,strong) UITableView *listView;
@end
