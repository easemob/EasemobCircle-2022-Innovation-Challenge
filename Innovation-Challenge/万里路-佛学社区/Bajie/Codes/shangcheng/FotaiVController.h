//
//  FotaiVController.h
//  Xuefoqifu
//
//  Created by MingmingSun on 2019/3/10.
//  Copyright © 2019 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FotaiVController : UIViewController

- (id)initWithFoName:(NSString*)aFoName
        andXiangID:(int)aXiangID
      andVoterName:(NSString*)voterName
          andKunit:(CGFloat)akunit;

-(void)setFoName:(NSString*)aFoName;
-(void)setXiangID:(int)aXiangID;
-(void)setVoterName:(NSString*)aVoterName;

@end

NS_ASSUME_NONNULL_END
