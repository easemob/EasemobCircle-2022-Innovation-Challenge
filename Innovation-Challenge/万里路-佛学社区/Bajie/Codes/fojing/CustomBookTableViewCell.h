//
//  CustomBookTableViewCell.h
//  XuefoQiFu
//
//  Created by Mac on 2021/5/25.
//  Copyright © 2021 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomBookTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bookImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;

@end

NS_ASSUME_NONNULL_END
