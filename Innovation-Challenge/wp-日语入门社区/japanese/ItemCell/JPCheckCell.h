//
//  JPCheckCell.h
//  japanese
//
//  Created by LYQ on 2021/29.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "UIKit/UIKit.h"

@interface JPCheckCell : UICollectionViewCell
@property (nonatomic, strong)UILabel *title;
@property (nonatomic, readonly)NSInteger state;

typedef enum {
    StateNormal = 0,
    StateRight,
    StateCliked
} JPCheckCellState;
-(void)setCheckState:(JPCheckCellState)state;
@end
