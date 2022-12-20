//
//  GongDeTableViewCell.h
//  XuefoQiFu
//
//  Created by Mac on 2022/1/24.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GongDeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;
@property (weak, nonatomic) IBOutlet UILabel *userCountLb;
@property (weak, nonatomic) IBOutlet UILabel *paiMingLb;
@property (weak, nonatomic) IBOutlet UIImageView *brigdeImg;

@end

NS_ASSUME_NONNULL_END
