//
//  JPCheckCell.m
//  japanese
//
//  Created by LYQ on 2021/29.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "JPCheckCell.h"
#import "JPUtils.h"

@interface JPCheckCell()

    @property (nonatomic, readwrite)NSInteger state;

@end
@implementation JPCheckCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
        self.title.font = [UIFont systemFontOfSize:17];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.textColor = [UIColor whiteColor];

        self.backgroundColor = UIColor.systemPinkColor;
        [self addSubview:self.title];
        self.state = StateNormal;
    }

    return self;
}

-(void)setCheckState:(JPCheckCellState)state {
    self.state = state;
    [self setNeedsDisplay];
    if (self.state == StateRight){
        self.title.text = @"";
        self.backgroundColor = [UIColor whiteColor];
    } else{
        self.backgroundColor = UIColor.systemPinkColor;
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.state == StateCliked){
        CGContextSetFillColorWithColor(context, JPCheckCellClickedColor.CGColor);
    } else if (self.state == StateNormal){
        CGContextSetFillColorWithColor(context, JPCheckCellNormalColor.CGColor);
    } else if (self.state == StateRight){
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextAddArc(context,(rect.size.width)/2, rect.size.height-2*7.5, 7.5, 0, 2*M_PI,0);
    CGContextDrawPath(context, kCGPathFill);
}
@end
