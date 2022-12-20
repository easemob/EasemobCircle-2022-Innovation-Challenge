//
//  FoSheQuViewController.m
//  XuefoQiFu
//
//  Created by Mac on 2022/12/16.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import "FoSheQuViewController.h"
#import "FoSheQuListViewController.h"
#import <SVProgressHUD.h>
@import HyphenateChat;

@interface FoSheQuViewController ()

@end

@implementation FoSheQuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _oneClickBtn.clipsToBounds = true;
    _oneClickBtn.layer.cornerRadius = 10;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [[EMClient sharedClient] logout:true];
}

- (IBAction)creatNewAccountBtn:(id)sender {
    NSUserDefaults *tempD = [NSUserDefaults standardUserDefaults];
    NSString *tName = [tempD objectForKey:@"username"];
    NSString *tPass = [tempD objectForKey:@"password"];
    if(tName){
//        if([tempD objectForKey:@"password"] ){
            [[EMClient sharedClient] loginWithUsername:tName
                                                 password:tPass
                                               completion:^(NSString *aUsername, EMError *aError) {
                
//
//                EMCircleServerAttribute *a = [[EMCircleServerAttribute alloc] init];
//                a.name = @"论禅社区";
//                a.icon = @"";
//                a.desc = @"每日阅读，品佛经，论禅经";
//                a.ext = @"无";
//                [[[EMClient sharedClient] circleManager] createServer:a completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {
//
//                }];
//
//                EMCircleServerAttribute *b = [[EMCircleServerAttribute alloc] init];
//                b.name = @"自由发言";
//                b.icon = @"";
//                b.desc = @"畅所欲言，互相交流";
//                b.ext = @"无";
//                [[[EMClient sharedClient] circleManager] createServer:b completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {
//
//                }];
//
                [SVProgressHUD show];
                [[[EMClient sharedClient] circleManager] joinServer:@"1GKXe4BFNEWTcOdnMf7vT1CglTs" completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {

                    [[[EMClient sharedClient] circleManager] joinServer:@"1GKXe5J6isIGOOn0EJAw2ktDUgp" completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {
                        
                        [[[EMClient sharedClient] circleManager] joinServer:@"1GUhrCm6QDgSeA7bD04wctU0Bph" completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {

                            [[[EMClient sharedClient] circleManager] joinServer:@"1GUhr7FrMrqpiMZqODZz9Kv9oao" completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {
                                [SVProgressHUD showSuccessWithStatus:@"成功，正在进入社区"];
                                [SVProgressHUD dismissWithDelay:1.0];
                                FoSheQuListViewController *v = [[FoSheQuListViewController alloc] init];
                                [self.navigationController pushViewController:v animated:true];
                            }];
                        }];
                    }];
                }];
                
                
            }];
            
//        }else{
//            NSLog(@"No Password");
//
//        }
    }else{
        
        
//        [[[EMClient sharedClient] circleManager] fetc]
        
        
        NSLog(@"No Name");
        // 异步方法
            long y = (arc4random() % 89999) + 10000;

            NSString *nameStr = [NSString stringWithFormat:@"User%ld",y];
            NSString *pasStr = [self randomPassword];
        
        //admin
//        NSString *nameStr = [NSString stringWithFormat:@"admin"];
//        NSString *pasStr = @"admin8888";
        
        [[EMClient sharedClient] registerWithUsername:nameStr
                                                 password:pasStr
                                               completion:^(NSString *aUsername, EMError *aError) {

            if(!aError){
                NSUserDefaults *tempD = [NSUserDefaults standardUserDefaults];
                [tempD setObject:nameStr forKey:@"username"];
                [tempD setObject:pasStr forKey:@"password"];
                [tempD synchronize];
                [[EMClient sharedClient] loginWithUsername:nameStr
                                                     password:pasStr
                                                completion:^(NSString *aUsername, EMError *aError) {
                    if(!aError){
                        
                        //admin
                        [[[EMClient sharedClient] circleManager] fetchJoinedServers:20 cursor:nil completion:^(EMCursorResult<EMCircleServer *> * _Nullable result, EMError * _Nullable error) {
                            for (int i = 0; i<result.list.count; i++) {
                                EMCircleServer *c = result.list[i];
                                NSLog(@"%@",c.serverId);
                            }
                        }];
                        [SVProgressHUD show];
                        //新用户加入社区
                        [[[EMClient sharedClient] circleManager] joinServer:@"1GKXe4BFNEWTcOdnMf7vT1CglTs" completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {

                            [[[EMClient sharedClient] circleManager] joinServer:@"1GKXe5J6isIGOOn0EJAw2ktDUgp" completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {
                                
                                [[[EMClient sharedClient] circleManager] joinServer:@"1GUhrCm6QDgSeA7bD04wctU0Bph" completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {

                                    [[[EMClient sharedClient] circleManager] joinServer:@"1GUhr7FrMrqpiMZqODZz9Kv9oao" completion:^(EMCircleServer * _Nullable server, EMError * _Nullable error) {
                                        [SVProgressHUD showSuccessWithStatus:@"成功，正在进入社区"];
                                        [SVProgressHUD dismissWithDelay:1.0];
                                        FoSheQuListViewController *v = [[FoSheQuListViewController alloc] init];
                                        [self.navigationController pushViewController:v animated:true];
                                    }];
                                }];
                            }];
                        }];
                    }else{
                        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"自动登录失败:%@",aError.errorDescription]];
                    }
                    
                }];
            }
    else{
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"自动注册失败:%@",aError.errorDescription]];
            }





         }];
    }
    
}
-(NSString *)randomPassword{
    //自动生成8位随机密码
    NSTimeInterval random=[NSDate timeIntervalSinceReferenceDate];
    NSLog(@"now:%.8f",random);
    NSString *randomString = [NSString stringWithFormat:@"%.8f",random];
    NSString *randompassword = [[randomString componentsSeparatedByString:@"."]objectAtIndex:1];
    NSLog(@"randompassword:%@",randompassword);

    return randompassword;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
