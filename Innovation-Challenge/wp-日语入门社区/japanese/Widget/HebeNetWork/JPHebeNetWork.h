//
// Created by LYQ on 16/8/5.
// Copyright (c) 2020 LYQ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JPHebeNetWork : NSObject

+(NSDictionary *)getParams;
+(void)setDebug:(BOOL)isDebug;
+(void)get:(NSString *)partUrl params:(NSMutableDictionary *)params success:(void(^)(NSString *data))succ fail:(void(^)(NSString *data))fail;
+(void)post:(NSString *)partUrl params:(NSMutableDictionary *)params success:(void(^)(NSString *data))succ fail:(void(^)(NSString *data))fail;
+(void)postjson:(NSString *)partUrl params:(NSMutableDictionary *)params successjson:(void(^)(id json))successjson fail:(void(^)(NSString *data))fail;
+(void)uploadOneData:(NSString *)partUrl params:(NSMutableDictionary *)params data:(NSData *)data mimetype:(NSString *)mimetype fileKeyName:(NSString *)filekey fileName:(NSString *)filename success:(void(^)(NSString *data))succ fail:(void(^)(NSString *data))fail;
+(void)loadImage:(UIImageView *)imageView imageurl:(NSString *)imageUrl;
@end
