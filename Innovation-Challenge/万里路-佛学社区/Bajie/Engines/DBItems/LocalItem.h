//
//  LocalItem.h
//  Xuefoqifu
//
//  Created by MingmingSun on 16/9/26.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalItem : NSObject
//功德值
@property(nonatomic,assign) int spID;
@property(nonatomic,assign) int godindex;
@property(nonatomic,assign) int xiangkind;
@property(nonatomic,strong) NSDate* xiangtime;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
