//
//  PCReaderViewController.h
//  PCReaderDemo
//
//  Created by LYQ on 22/3/9.
//  Copyright (c) 2019年 com.duowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCReaderViewController : UIViewController<UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) UICollectionView *collectionView;

- (void)loadText:(NSString *)text;

@end

@protocol PCFontAdjustViewDelegate <NSObject>

- (void)adjustRangeArrayForText;

@end

@interface PCFontAdjustView : UIView

@property (nonatomic, weak) id<PCFontAdjustViewDelegate>delegate;

@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) UIButton *minusButton;

@end
