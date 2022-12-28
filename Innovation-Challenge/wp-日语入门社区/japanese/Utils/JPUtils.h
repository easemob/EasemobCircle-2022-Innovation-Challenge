//
//  JPUtils.h
//  japanese
//
//  Created by LYQ on 2021/27.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "AVFoundation/AVFoundation.h"

@interface JPUtils : NSObject

+(NSMutableArray *)getQYSoundArray;
+(NSMutableArray *)getQAYSoundArray;
+(NSMutableArray *)getZYSoundArray;
+(NSMutableArray *)getZAYSoundArray;
+(NSMutableArray *)getTypeArray:(NSInteger)type arraycount:(NSInteger)count;
+(UIColor *)getUIColorByString:(NSString *)hexcolor;
@end
