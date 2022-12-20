//
//  DuHuanTableViewCell.h
//  XuefoQiFu
//
//  Created by Mac on 2022/1/25.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>
NS_ASSUME_NONNULL_BEGIN

@interface DuHuanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *giftView1;
@property (weak, nonatomic) IBOutlet UIImageView *giftImg1;
@property (weak, nonatomic) IBOutlet UILabel *giftTitleLb1;
@property (weak, nonatomic) IBOutlet UIButton *giftCheckBtn1;
@property (weak, nonatomic) IBOutlet UIButton *giftDHBtn1;
@property (weak, nonatomic) IBOutlet UILabel *gdLb1;

@property (weak, nonatomic) IBOutlet UIView *giftView2;
@property (weak, nonatomic) IBOutlet UIImageView *giftImg2;
@property (weak, nonatomic) IBOutlet UILabel *giftTitleLb2;
@property (weak, nonatomic) IBOutlet UIButton *giftCheckBtn2;
@property (weak, nonatomic) IBOutlet UIButton *giftDHBtn2;
@property (weak, nonatomic) IBOutlet UILabel *gdLb2;

@property(nonatomic,strong)BmobObject *mainB1;
@property(nonatomic,strong)BmobObject *mainB2;

@end

NS_ASSUME_NONNULL_END
