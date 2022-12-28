//
//  JPPeekSoundPreViewController.m
//  japanese
//
//  Created by LYQ on 2021/28.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "JPPeekSoundPreViewController.h"
#import "JPSoundCell.h"
#import "JPSoundBean.h"

@implementation JPPeekSoundPreViewController

- (void)viewDidLoad {
    JPSoundCell *cell = [[JPSoundCell alloc] initWithFrame:CGRectMake((self.view.frame.size.width-100)/2,StartY+50,100,80)];
    cell.pingjia.text = self.bean.pingjia;
    cell.pianjia.text = self.bean.pianjia;
    cell.luoma.text = self.bean.luoma;
    [self.view addSubview:cell];
}
@end
