//
//  DeliverTableViewCell.h
//  XuefoQiFu
//
//  Created by Mac on 2022/1/27.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeliverTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *productTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *receveMsgLb;
@property (weak, nonatomic) IBOutlet UILabel *addressLb;
@property (weak, nonatomic) IBOutlet UILabel *statuLb;

@end

NS_ASSUME_NONNULL_END
