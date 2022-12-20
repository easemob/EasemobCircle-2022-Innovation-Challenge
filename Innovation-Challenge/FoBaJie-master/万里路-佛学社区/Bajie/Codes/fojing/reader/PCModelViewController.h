//
//  PCModelViewController.h
//  PCReaderDemo
//
//  Created by LYQ on 22/3/9.
//  Copyright (c) 2019年 com.duowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCDataViewController.h"
#import "PCReaderViewController.h"

#define kAdjustFontNotification     @"kAdjustFontNotification"

@interface PCModelViewController : NSObject<UIPageViewControllerDataSource>

@property (weak, nonatomic) PCReaderViewController *readerController;
@property (strong, nonatomic) NSArray *pageData;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSDictionary *attributes;

- (PCDataViewController *)viewControllerAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfViewController:(PCDataViewController *)viewController;

@end
