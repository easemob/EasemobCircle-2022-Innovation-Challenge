//
//  FoChannelListViewController.h
//  XuefoQiFu
//
//  Created by Mac on 2022/12/16.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoChannelListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property(nonatomic,copy)NSString *serverId;
@end

NS_ASSUME_NONNULL_END
