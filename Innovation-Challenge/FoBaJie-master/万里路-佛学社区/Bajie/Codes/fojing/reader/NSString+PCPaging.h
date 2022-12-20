//
//  NSString+PCPaging.h
//  PCReaderDemo
//
//  Created by LYQ on 22/3/10.
//  Copyright (c) 2019年 com.duowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (PCPaging)

- (NSArray *)paginationWithAttributes:(NSDictionary *)attributes constrainedToSize:(CGSize)size;

- (NSString *)halfWidthToFullWidth;

@end
