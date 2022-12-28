//
//  JPBaseViewController.m
//  firstiosapp
//
//  Created by LYQ on 16/7/25.
//  Copyright © 2020年 LYQ. All rights reserved.
//

#import "JPBaseViewController.h"

@interface JPBaseViewController ()<UIAlertViewDelegate>
@property (retain, nonatomic)UIAlertView *alertView;
@end

@implementation JPBaseViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)getUIColorByString:(NSString *)hexcolor {
    NSMutableString *color = [hexcolor copy];
// 转换成标准16进制数
    [color replaceCharactersInRange:[color rangeOfString:@"#" ] withString:@"0x"];
// 十六进制字符串转成整形。
    long colorLong = strtoul([color cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
// 通过位与方法获取三色值
    int R = (colorLong & 0xFF0000 )>>16;
    int G = (colorLong & 0x00FF00 )>>8;
    int B =  colorLong & 0x0000FF;

//string转color
    return [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0];
}

- (void)saveObjConf:(nullable id)config key:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:config forKey:key];
    [ud synchronize];

}

- (void)saveIntConf:(NSInteger)config key:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:config forKey:key];
    [ud synchronize];
}

- (void)saveBoolConf:(BOOL)config key:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:config forKey:key];
    [ud synchronize];
}

- (void)saveFloatConfg:(CGFloat)config key:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setFloat:config forKey:key];
    [ud synchronize];
}

- (void)saveDoubleConfg:(CGFloat)config key:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setDouble:config forKey:key];
    [ud synchronize];
}

- (id)getObjConfig:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:key];
}
- (NSInteger)getIntConfig:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud integerForKey:key];
}
- (BOOL)getBoolConfig:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:key];
}
- (CGFloat)getFloatConfig:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud floatForKey:key];
}
- (double)getDoubleConfig:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud doubleForKey:key];
}
- (void)removeObjConfig:(NSString *)key{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:key];
    [ud synchronize];
}

- (void)clearConfig{
    NSString*appDomain = [[NSBundle mainBundle]bundleIdentifier];
    [[NSUserDefaults standardUserDefaults]removePersistentDomainForName:appDomain];
}

@end
