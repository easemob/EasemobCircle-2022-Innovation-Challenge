//
//  UserInfoItem.h
//  Xuefoqifu
//
//  Created by admin on 2019/3/12.
//  Copyright © 2019 Sunmingming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoItem : NSObject

@property(nonatomic,assign) int spID;
@property(nonatomic,strong) NSString *username;//姓名
@property(nonatomic,strong) NSString *sex;
@property(nonatomic,strong) NSString *city;
@property(nonatomic,strong) NSString *birthday;
@property(nonatomic,strong) NSString *btime;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
