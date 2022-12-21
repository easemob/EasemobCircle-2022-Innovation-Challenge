//
//  PCCollectViewModel.h
//  PCReaderDemo
//
//  Created by LYQ on 22/3/17.
//  Copyright (c) 2019年 com.duowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCollectViewModel : NSObject<UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *attributes;

@end
