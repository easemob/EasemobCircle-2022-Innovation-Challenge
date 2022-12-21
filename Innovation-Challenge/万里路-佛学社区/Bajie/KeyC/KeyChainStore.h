//
//  KeyChainStore.h
//  XuefoQiFu
//
//  Created by Mac on 2022/2/1.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface KeyChainStore : NSObject
 
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;
 
@end

NS_ASSUME_NONNULL_END
