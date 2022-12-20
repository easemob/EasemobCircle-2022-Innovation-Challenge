//
//  PCPageView.h
//  PCPageDemo
//
//  Created by LYQ on 22/3/10.
//  Copyright (c) 2019年 com.duowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCPageView : UIView

@property (nonatomic, copy) NSAttributedString *attributedText;

- (void)setText:(NSAttributedString *)attributedText;

@end
