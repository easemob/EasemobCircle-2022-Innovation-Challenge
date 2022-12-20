//
//  YWTableViewCell.m
//  Xuefoqifu
//
//  Created by MingmingSun on 2019/1/12.
//  Copyright © 2019 Sunmingming. All rights reserved.
//

#import "YWTableViewCell.h"

@implementation YWTableViewCell

- (void)awakeFromNib {
	[super awakeFromNib];
	// Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// configure control(s)
		self.bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, 140)];
		self.bgImgView.image = [UIImage imageNamed:@"fo_bg.jpg"];
		[self.bgImgView setContentMode:UIViewContentModeScaleToFill];
		[self addSubview:self.bgImgView];
		
		self.foImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 96, 120)];
		self.foImgView.image = [UIImage imageNamed:@"3-131214154509137.jpg"];
		[self.foImgView setContentMode:UIViewContentModeScaleToFill];
		[self addSubview:self.foImgView];
		
		self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, kDeviceWidth - 120, 15)];
		self.numberLabel.textColor = [UIColor darkGrayColor];
		self.numberLabel.textAlignment = NSTextAlignmentLeft;
		self.numberLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
		[self addSubview:self.numberLabel];
		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 25, kDeviceWidth - 120, 15)];
		self.nameLabel.textColor = [UIColor darkGrayColor];
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
		[self addSubview:self.nameLabel];
		
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 40, kDeviceWidth - 120, 20)];
		self.titleLabel.textColor = [UIColor blackColor];
		self.titleLabel.textAlignment = NSTextAlignmentLeft;
		self.titleLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
		self.titleLabel.numberOfLines = 1;
		self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		[self addSubview:self.titleLabel];
		
		self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 60, kDeviceWidth - 120, 50)];
		self.mainLabel.textColor = [UIColor blackColor];
		self.mainLabel.textAlignment = NSTextAlignmentLeft;
		self.mainLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
		self.mainLabel.numberOfLines = 3;
		self.mainLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		[self addSubview:self.mainLabel];
		
		self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 110, kDeviceWidth - 120, 20)];
		self.dateLabel.textColor = [UIColor darkGrayColor];
		self.dateLabel.textAlignment = NSTextAlignmentLeft;
		self.dateLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
		[self addSubview:self.dateLabel];
		
		self.moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 110, kDeviceWidth - 120, 20)];
		self.moneyLabel.textColor = [UIColor darkGrayColor];
		self.moneyLabel.textAlignment = NSTextAlignmentRight;
		self.moneyLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
		[self addSubview:self.moneyLabel];
        
        self.completBtn = [[UIButton alloc]initWithFrame:CGRectMake(kDeviceWidth-120, 50, 80, 40)];
        [self.completBtn setTitle:@"我要还愿" forState:UIControlStateNormal];
        [self.completBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.completBtn.backgroundColor = mainColor;
        self.completBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        self.completBtn.layer.borderColor = [UIColor blackColor].CGColor;
        self.completBtn.layer.borderWidth = 1.0;
//        [self addSubview:self.completBtn];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

@end
