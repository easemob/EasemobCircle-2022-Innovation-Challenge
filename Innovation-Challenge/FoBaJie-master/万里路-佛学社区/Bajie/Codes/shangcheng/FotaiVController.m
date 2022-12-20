//
//  FotaiVController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 2019/3/10.
//  Copyright © 2019 Sunmingming. All rights reserved.
//

#import "FotaiVController.h"
#import "tooles.h"
#import <Masonry.h>

@interface FotaiVController ()

@property(nonatomic,strong) UIImageView *LUImageView;
@property(nonatomic,strong) UIImageView *RUImageView;
@property(nonatomic,strong) UIImageView *LFireImageView;
@property(nonatomic,strong) UIImageView *RFireImageView;
@property(nonatomic,strong) UIImageView *FoImageView;
@property(nonatomic,strong) UIImageView *LDImageView;
@property(nonatomic,strong) UIImageView *RDImageView;
@property(nonatomic,strong) UIImageView *FlowerImageView;

@property(nonatomic,strong) UIImageView *VoterBgImageView;
@property(nonatomic,strong) UILabel *VoterNameLabel;

@end

@implementation FotaiVController

- (id)initWithFoName:(NSString*)aFoName
				andXiangID:(int)aXiangID
			andVoterName:(NSString*)voterName
          andKunit:(CGFloat)akunit
{
	self = [super init];
	if (self) {
		CGFloat kunit = akunit;
		
		self.view.frame = CGRectMake(0, 0, kunit, kunit * 468/566);
		self.view.backgroundColor = [UIColor clearColor];
		
		self.LUImageView = [UIImageView new];
		self.LUImageView.image = [UIImage imageNamed:@"fo_bg_tl.jpg"];
		self.LUImageView.frame = CGRectMake(0, 0, kunit * 122/566, kunit * 309/566);
		[self.view addSubview:self.LUImageView];
		
		self.RUImageView = [UIImageView new];
		self.RUImageView.image = [UIImage imageNamed:@"fo_bg_tr.jpg"];
		self.RUImageView.frame = CGRectMake(kunit * 444/566, 0, kunit * 122/566, kunit * 309/566);
		[self.view addSubview:self.RUImageView];
		
		self.LFireImageView = [UIImageView new];
		self.LFireImageView.image = [UIImage imageNamed:@"fo_gd_l.gif"];
		self.LFireImageView.frame = CGRectMake(kunit * 122/566, 0, kunit * 37/566, kunit * 309/566);
		[self.view addSubview:self.LFireImageView];
		
		self.RFireImageView = [UIImageView new];
		self.RFireImageView.image = [UIImage imageNamed:@"fo_gd_r.gif"];
		self.RFireImageView.frame = CGRectMake(kunit * 407/566, 0, kunit * 37/566, kunit * 309/566);
		[self.view addSubview:self.RFireImageView];
		
		self.FoImageView = [UIImageView new];
		self.FoImageView.image = [UIImage imageNamed:[tooles getPicNameByFoName:aFoName]];
		self.FoImageView.frame = CGRectMake(kunit * 159/566, 0, kunit * 248/566, kunit * 309/566);
		[self.view addSubview:self.FoImageView];
		
		self.LDImageView = [UIImageView new];
		self.LDImageView.image = [UIImage imageNamed:@"fo_bg_bl.jpg"];
		self.LDImageView.frame = CGRectMake(0, kunit * 309/566, kunit * 224/566, kunit * 159/566);
		[self.view addSubview:self.LDImageView];
		
		self.RDImageView = [UIImageView new];
		self.RDImageView.image = [UIImage imageNamed:@"fo_bg_br.jpg"];
		self.RDImageView.frame = CGRectMake(kunit * 342/566, kunit * 309/566, kunit * 224/566, kunit * 159/566);
		[self.view addSubview:self.RDImageView];
		
		self.FlowerImageView = [UIImageView new];
		self.FlowerImageView.image = [UIImage imageNamed:[tooles getXiangPicNameByXiangID:aXiangID]];
		self.FlowerImageView.frame = CGRectMake(kunit * 224/566, kunit * 309/566, kunit * 118/566, kunit * 159/566);
		[self.view addSubview:self.FlowerImageView];
		
		self.VoterBgImageView = [UIImageView new];
		self.VoterBgImageView.image = [UIImage imageNamed:@"shaoxiang_xm.jpg"];
		self.VoterBgImageView.frame = CGRectMake(kunit / 6, kunit * 421/ 566, kunit * 2/3, kunit / 18);
		[self.view addSubview:self.VoterBgImageView];
		
		self.VoterNameLabel = [UILabel new];
		self.VoterNameLabel.text = [NSString stringWithFormat:@"善信: %@", voterName];
		self.VoterNameLabel.textAlignment = NSTextAlignmentCenter;
		self.VoterNameLabel.font = [UIFont flatFontOfSize:kunit/25];
		self.VoterNameLabel.frame = self.VoterBgImageView.frame;
		[self.view addSubview:self.VoterNameLabel];
		
		if (voterName.length <= 0) {
			self.VoterNameLabel.hidden = YES;
			self.VoterBgImageView.hidden = YES;
		} else {
			self.VoterNameLabel.hidden = NO;
			self.VoterBgImageView.hidden = NO;
		}
	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

-(void)setFoName:(NSString*)aFoName {
//    self.FoImageView.backgroundColor = [UIColor clearColor];
//    self.FoImageView.layer.cornerRadius = 20;
//    self.FoImageView.clipsToBounds = true;
//    [UIView animateWithDuration:0.5 animations:^{
//        self.FoImageView.alpha = 0.0;
//    } completion:^(BOOL finished) {
//
//        [UIView animateWithDuration:0.5 animations:^{
//
            self.FoImageView.image = [UIImage imageNamed:[tooles getPicNameByFoName:aFoName]];
//            self.FoImageView.alpha = 1;
//        }];
//    }];
    
}

-(void)setVoterName:(NSString*)aVoterName {
	self.VoterNameLabel.text = [NSString stringWithFormat:@"善信: %@", aVoterName];
	if (aVoterName.length <= 0) {
		self.VoterNameLabel.hidden = YES;
		self.VoterBgImageView.hidden = YES;
	} else {
		self.VoterNameLabel.hidden = NO;
		self.VoterBgImageView.hidden = NO;
	}
}

-(void)setXiangID:(int)aXiangID {
    self.FlowerImageView.image = [UIImage imageNamed:[tooles getXiangPicNameByXiangID:aXiangID]];
}

@end
