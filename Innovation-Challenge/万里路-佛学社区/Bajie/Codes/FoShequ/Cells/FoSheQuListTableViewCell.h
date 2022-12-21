//
//  FoSheQuListTableViewCell.h
//  XuefoQiFu
//
//  Created by Mac on 2022/12/16.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HyphenateChat;
NS_ASSUME_NONNULL_BEGIN

@interface FoSheQuListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *servesName;
@property (weak, nonatomic) IBOutlet UILabel *servesDesc;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UIButton *deleteChannelBtn;
@property (weak, nonatomic) IBOutlet UILabel *addMemb;
@property(nonatomic,strong)EMCursorResult<EMCircleUser *> *results;
@property(nonatomic,copy)NSString *serverId;
@property(nonatomic,copy)NSString *channelId;

-(void)updateMemb;
@end

NS_ASSUME_NONNULL_END
