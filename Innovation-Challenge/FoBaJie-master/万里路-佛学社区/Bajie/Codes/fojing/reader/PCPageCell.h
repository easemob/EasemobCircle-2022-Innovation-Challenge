//
//  PCPageCell.h
//  PCReaderDemo
//
//  Created by LYQ on 22/3/17.
//  Copyright (c) 2019年 com.duowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCPageView.h"

static NSString *PageCellIdentifier = @"PageCellIdentifier";

@interface PCPageCell : UICollectionViewCell

@property (nonatomic, strong) PCPageView *pageView;

@end
