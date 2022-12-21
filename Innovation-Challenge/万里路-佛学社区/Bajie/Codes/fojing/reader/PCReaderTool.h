//
//  PCReaderTool.h
//  OJia
//
//  Created by LYQ on 22/3/23.
//  Copyright (c) 2019年 com.ojia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BatteryMonitorBlock)(CGFloat batteryLevel);
typedef void(^TimeMonitorBlock)(NSDate *currentDate);

@interface PCReaderTool : NSObject

- (void)startMonitorBatteryWithBlock:(BatteryMonitorBlock)block;

- (void)stopMonitorBattery;

- (void)startMonitorTimeWithBlock:(TimeMonitorBlock)block;

- (void)stopMonitorTime;

@end
