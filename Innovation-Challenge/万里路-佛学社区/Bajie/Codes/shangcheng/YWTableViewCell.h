//
//  YWTableViewCell.h
//  Xuefoqifu
//
//  Created by MingmingSun on 2019/1/12.
//  Copyright © 2019 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YWTableViewCell : UITableViewCell

// now only showing one label, you can add more yourself
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIImageView *foImgView;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *praiseLabel;
@property (nonatomic, strong) UIButton *completBtn;
@end

NS_ASSUME_NONNULL_END
