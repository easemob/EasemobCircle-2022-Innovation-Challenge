//
//  JPSoundCell.m
//  japanese
//
//  Created by LYQ on 2021/27.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "JPSoundCell.h"
#import "JPUtils.h"

@implementation JPSoundCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.pingjia = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width/2,frame.size.height/2)];
        self.pianjia = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2,self.pingjia.frame.origin.y,frame.size.width/2,frame.size.height/2)];
        self.luoma = [[UILabel alloc] initWithFrame:CGRectMake(0,self.pianjia.frame.origin.y+self.pianjia.frame.size.height,frame.size.width,frame.size.height/2)];
        self.pingjia.textAlignment = NSTextAlignmentCenter;
        self.pianjia.textAlignment = NSTextAlignmentCenter;
        self.luoma.textAlignment = NSTextAlignmentCenter;

        self.pingjia.textColor = [UIColor redColor];
        self.pianjia.textColor = [UIColor blueColor];
        self.luoma.textColor = [UIColor whiteColor];
        self.backgroundColor = UIColor.systemGreenColor;

        self.pingjia.font = [UIFont systemFontOfSize:20];
        self.pianjia.font = [UIFont systemFontOfSize:16];
        self.luoma.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.pingjia];
        [self addSubview:self.pianjia];
        [self addSubview:self.luoma];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

}
@end
