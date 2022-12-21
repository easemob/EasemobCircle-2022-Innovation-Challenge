//
//  LocalItem.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/9/26.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "LocalItem.h"
#import <LKDBHelper.h>

@implementation LocalItem

//重载选择 使用的LKDBHelper
+(LKDBHelper *)getUsingLKDBHelper
{
    static LKDBHelper* db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        NSString* dbpath = [NSHomeDirectory() stringByAppendingPathComponent:@"asd/asd.db"];
        //        NSLog(@"%@",dbpath);
        //        db = [[LKDBHelper alloc]initWithDBPath:dbpath];
        //or
        db = [[LKDBHelper alloc]init];
    });
    return db;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [self init])
    {
        self.godindex = [[dictionary valueForKey:@"godindex"] intValue];
        self.xiangkind = [[dictionary valueForKey:@"xiangkind"] intValue];
        self.xiangtime = [dictionary valueForKey:@"xiangtime"];
    }
    return self;
}

-(id)init
{
    if(self = [super init])
    {
        self.spID = 1;
        self.godindex = 0;
        self.xiangkind = 0;
        self.xiangtime = [NSDate date];
    }
    return self;
}

//在类 初始化的时候
+(void)initialize
{
    //enable the column binding property name
    //[self setTableColumnName:@"id" bindingPropertyName:@"dbid"];
}

//主键
+(NSString *)getPrimaryKey
{
    return @"spID";
}

//表名
+(NSString *)getTableName
{
    return @"sp_local";
}

@end
