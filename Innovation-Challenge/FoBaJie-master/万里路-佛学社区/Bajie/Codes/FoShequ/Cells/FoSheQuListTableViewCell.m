//
//  FoSheQuListTableViewCell.m
//  XuefoQiFu
//
//  Created by Mac on 2022/12/16.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import "FoSheQuListTableViewCell.h"
@import HyphenateChat;
@implementation FoSheQuListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateMemb;{
    [[[EMClient sharedClient] circleManager] fetchChannelMembers:self.serverId channelId:self.channelId limit:20 cursor:nil completion:^(EMCursorResult<EMCircleUser *> * _Nullable result, EMError * _Nullable error) {
        self.results = result;
        self.addMemb.text = [NSString stringWithFormat:@"参与人数:%ld",result.list.count+100];
    }];
}

@end
