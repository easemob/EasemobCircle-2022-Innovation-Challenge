//
//  JPSoundBean.m
//  japanese
//
//  Created by LYQ on 2021/27.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "JPSoundBean.h"

@implementation JPSoundBean

- (instancetype)initWith:(NSString *)pingjia pianjia:(NSString *)pianjia luoma:(NSString *)luoma {
    if (self = [super init]){
        self.pingjia = pingjia;
        self.pianjia = pianjia;
        self.luoma = luoma;
        self.shuru = luoma;
        return self;
    } else{
        return nil;
    }
}

- (instancetype)initWith:(NSString *)pingjia pianjia:(NSString *)pianjia luoma:(NSString *)luoma shuru:(NSString *)shuru{
    if (self = [super init]){
        self.pingjia = pingjia;
        self.pianjia = pianjia;
        self.luoma = luoma;
        self.shuru = shuru;
        return self;
    } else{
        return nil;
    }
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.pingjia=%@", self.pingjia];
    [description appendFormat:@", self.pianjia=%@", self.pianjia];
    [description appendFormat:@", self.luoma=%@", self.luoma];
    [description appendFormat:@", self.shuru=%@", self.shuru];
    [description appendFormat:@", self.checksound=%@", self.checksound];
    [description appendFormat:@", self.checktype=%@", self.checktype];
    [description appendFormat:@", self.checkState=%d", self.checkState];
    [description appendString:@">"];
    return description;
}


@end
