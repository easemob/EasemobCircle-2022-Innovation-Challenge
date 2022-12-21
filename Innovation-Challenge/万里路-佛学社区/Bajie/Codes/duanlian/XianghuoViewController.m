//
//  XianghuoViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/10/5.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "XianghuoViewController.h"
#import <SVProgressHUD.h>
#import "AppDelegate.h"
#import "tooles.h"
#import <Masonry.h>
#import <BmobSDK/Bmob.h>
#import "UUID.h"
@import GoogleMobileAds;
@interface XianghuoViewController ()<UITableViewDelegate,UITableViewDataSource,SKProductsRequestDelegate,SKPaymentTransactionObserver,GADFullScreenContentDelegate>{
    int tempAddFree;
}

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSArray *nameArray;
@property(nonatomic,strong) NSArray *priceArray;
@property(nonatomic,strong) NSArray *voteArray;
@property(nonatomic,assign) int nowIndex;
@property(nonatomic,copy)NSString *tempStr;

@property(nonatomic, strong) GADRewardedAd *rewardedAd;

@property (nonatomic,copy)NSMutableArray *dataArr;

@property(nonatomic,assign)Boolean isEarn;

@end

@implementation XianghuoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"选择香火种类";
		self.tableView = [UITableView new];
        _dataArr = [NSMutableArray array];
		self.tableView.dataSource = self;
		self.tableView.delegate = self;
		[self.view addSubview:self.tableView];
        BmobQuery   *bquery = [BmobQuery queryWithClassName:@"XiangHuoType"];
        //查找GameScore表的数据
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            for (BmobObject *obj in array) {
                [self->_dataArr addObject:obj];
            }
            [SVProgressHUD dismiss];
                [self.tableView reloadData];
        }];
		self.nameArray = @[@"清香",@"平安香",@"高升香",@"祈福香",@"鸿运香",@"长寿香",@"就业香",@"姻缘高香",@"求子高香",@"去病高香",@"学业高香",@"大圆满香"];
		self.priceArray = @[@"免费(+3~8功德)",@"1元(+10功德)",@"1元(+10功德)",@"1元(+10功德)",@"6元(+65功德)",@"6元(+65功德)",@"6元(+65功德)",@"18元(+200功德)",@"18元(+200功德)",@"18元(+200功德)",@"18元(+200功德)",@"68元(+800功德)"];
		self.voteArray = @[];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
//    [self loadRewardedAd];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	WS(ws);
	[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(ws.view);
	}];
	[self getVoting];
    
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

//- (void)loadRewardedAd {
//  GADRequest *request = [GADRequest request];
////    ca-app-pub-3940256099942544/1712485313
//    //ca-app-pub-9139925389247586/3964092018
//  [GADRewardedAd
//       loadWithAdUnitID:@"ca-app-pub-9139925389247586/3964092018"
//                request:request
//      completionHandler:^(GADRewardedAd *ad, NSError *error) {
//        if (error) {
//          NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
//
//          return;
//        }
//        self.rewardedAd = ad;
//        NSLog(@"Rewarded ad loaded.");
////      [self show];
//      self.rewardedAd.fullScreenContentDelegate = self;
//      }];
//}


/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad did present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    if(_isEarn){
        [self freeXH];
    }
   NSLog(@"Ad did dismiss full screen content.");
    
}

//- (void)show {
//  if (self.rewardedAd) {
//    [self.rewardedAd presentFromRootViewController:self
//                                  userDidEarnRewardHandler:^{
//                                  GADAdReward *reward =
//                                      self.rewardedAd.adReward;
//                                  // TODO: Reward the user!
////                                [self freeXH];
//        _isEarn = true;
//                                }];
//  } else {
//    NSLog(@"Ad wasn't ready");
//
//      UIAlertController *a = [UIAlertController alertControllerWithTitle:@"提示" message:@"广告尚未准备好，请再试一次或检查网络" preferredStyle:UIAlertControllerStyleAlert];
//      UIAlertAction *b = [UIAlertAction actionWithTitle:@"再试一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//          int x = arc4random() % 100;
//          if(x>=60){
//              [self freeXHSpec];
//          }else{
//              [self show];
//          }
//
//
//      }];
//      UIAlertAction *c = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//          int x = arc4random() % 100;
//          if(x>=60){
//              [self freeXHSpec];
//          }
//      }];
//      [a addAction:b];
//      [a addAction:c];
//      [self presentViewController:a animated:true completion:nil];
//  }
//}

-(void)getVoting{
//	AVQuery *query = [AVQuery queryWithClassName:@"MainTable"];
//	query.limit = 100;
//	[query orderByAscending:@"xiangid"];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//		if (!error && objects.count) {
//			self.voteArray = [NSArray arrayWithArray:objects];
//			[self.tableView reloadData];
//		} else {
////			[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取排名失败:%@", error]];
//		}
//	}];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 80.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return self.nameArray.count;
		default:
			return 0;
	}
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = nil;
	static NSString *inde = @"XianghuoCellID";
	cell = [tableView dequeueReusableCellWithIdentifier:inde];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"XianghuoCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	UILabel *lab1 = (UILabel*)[cell viewWithTag:1];
	UILabel *lab2 = (UILabel*)[cell viewWithTag:2];
	UILabel *lab4 = (UILabel*)[cell viewWithTag:3];
	UIImageView *headImg = (UIImageView*)[cell viewWithTag:99];
	
	lab1.text = [self.nameArray objectAtIndex:indexPath.row];
	if(self.dataArr.count == 0){
        lab2.text = @"";
	}else{
        BmobObject *v  = self.dataArr[indexPath.row];
        lab2.text = [NSString stringWithFormat:@"已有%@人上香",[v objectForKey:@"sxcs"]];
	}
    lab2.font = [UIFont systemFontOfSize:11];
	lab4.text = [self.priceArray objectAtIndex:indexPath.row];
    lab4.font = [UIFont systemFontOfSize:13];
	lab1.textColor = [UIColor blackColor];
	lab4.textColor = MMColorRed;
	if([lab4.text hasPrefix:@"免费(+3~8功德)"]){
		headImg.image = [UIImage imageNamed:@"xiang_free"];
	}else if([lab4.text hasPrefix:@"1元(+10功德)"]){
		headImg.image = [UIImage imageNamed:@"xiang_free"];
	}else if([lab4.text hasPrefix:@"6元(+65功德)"]){
		headImg.image = [UIImage imageNamed:@"xiang_middle"];
	}else if([lab4.text hasPrefix:@"18元(+200功德)"]){
        headImg.image = [UIImage imageNamed:@"xiang"];
    }else if([lab4.text hasPrefix:@"68元(+800功德)"]){
		headImg.image = [UIImage imageNamed:@"xiangB"];
	}
	return cell;
}

-(void)freeXH{
    [SVProgressHUD show];
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    NSLog(@"之前时间：%@", [userDefault objectForKey:@"nowDate"]);//之前存储的时间
    //    NSLog(@"现在时间%@",[NSDate date]);//现在的时间
    NSDate *now = [NSDate date];
        
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
    NSString *nowDateString = [dateFormatter stringFromDate:now];
    //    NSLog(@"日期比较：之前：%@ 现在：%@",ageDateString,nowDateString);
        

//         NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *idfv = [UUID getUUID];
         BmobQuery   *bquery = [BmobQuery queryWithClassName:@"ShaoXiangFree"];
         
         [bquery whereKey:@"UNIC" equalTo:idfv];
         
         [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
             if(error){
                 [SVProgressHUD dismiss];
                 [SVProgressHUD showWithStatus:@"请清香三支，持续24小时。"];
                 [SVProgressHUD dismissWithDelay:1.5f];
                 
             }else{
                 Boolean isAddNew = true;
                 [SVProgressHUD dismiss];
                 for(BmobObject *b in array){
                     NSString *lastStr = [dateFormatter stringFromDate:b.createdAt];
                     if([lastStr isEqualToString:nowDateString]){
                         NSString *msg = [NSString stringWithFormat:@"请清香三支，持续24小时。"];
                         UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请香成功" message:msg preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                             [self.navigationController popToRootViewControllerAnimated:true];
                         }];
                         [vc addAction:cancelAction];
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self presentViewController:vc animated:YES completion:nil];
                             _isEarn = false;
                         });
                         isAddNew = false;
                         break;
                     }else{
                         isAddNew = true;
                     }
                 }
                 
                 if(isAddNew){
                     BmobQuery   *bquery2 = [BmobQuery queryWithClassName:@"AppInfo"];
                     
                     [bquery2 whereKey:@"UNIC" equalTo:idfv];
                     [bquery2 findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                         for (BmobObject *b in array) {
                             NSInteger gd = [[b objectForKey:@"GongDeCounts"] integerValue];
                             tempAddFree = arc4random() % 5 + 3;
                             gd+=tempAddFree;
                             [b setObject:[NSNumber numberWithInteger:gd] forKey:@"GongDeCounts"];
                             [b updateInBackground];
                         }
                         
                         BmobObject *b = [BmobObject objectWithClassName:@"ShaoXiangFree"];
                         [b setObject:idfv forKey:@"UNIC"];
                         [b setObject:@"0" forKey:@"type"];
                         [b saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                             if(isSuccessful){
//                                 (arc4random() % 1000000)
                                
                                 NSString *msg = [NSString stringWithFormat:@"请清香三支，持续24小时。获取功德值+%d",tempAddFree];
                                 UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请香成功" message:msg preferredStyle:UIAlertControllerStyleAlert];
                                 UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                     [self.navigationController popToRootViewControllerAnimated:true];
                                 }];
                                 [vc addAction:cancelAction];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self presentViewController:vc animated:YES completion:nil];
                                     _isEarn = false;
                                 });
                             }
                         }];
                     }];
                 }
             }
         }];
         

    
    
    
    
}

//-(void)freeXHSpec{
//    NSString *msg = [NSString stringWithFormat:@"触发隐藏奖励：上善香，结善缘，恭喜您请清香三支，恭祝天天快乐日日精进。"];
//    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请香成功！" message:msg preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//        [self.navigationController popToRootViewControllerAnimated:true];
//    }];
//    [vc addAction:cancelAction];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentViewController:vc animated:YES completion:nil];
//        _isEarn = false;
//    });
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.row) {
		case 0:{
//			AVQuery *query = [AVQuery queryWithClassName:@"MainTable"];
//			[query whereKey:@"xiangid" equalTo:[NSNumber numberWithInt:1]];
//			[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//				if (!error && objects.count) {
//					AVObject *object = [objects firstObject];
//					[object incrementKey:@"xiangnum"];
//					[object saveInBackground];
//				} else {
//				}
//			}];
            APPALL.myLocalItem.xiangkind = (int)indexPath.row + 1;
            APPALL.myLocalItem.xiangtime = [NSDate date];
            [APPALL.myLocalItem saveToDB];
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"上善香" message:@"是否选择免费请清香三支。" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                
                [self freeXH];
                
            }];
            [a addAction:a1];
            [a addAction:a2];
            [self presentViewController:a animated:true completion:nil];
            
			
		}
			break;
		default:{
            self.nowIndex = (int)indexPath.row + 1;
//            APPALL.myLocalItem.xiangkind = (int)indexPath.row + 1;
//            APPALL.myLocalItem.xiangtime = [NSDate date];
//            [APPALL.myLocalItem saveToDB];
			NSString *yuanStr = [[self.priceArray objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"功德" withString:@"元"];
            yuanStr = [[self.priceArray objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"元)" withString:@"功德)"];
			UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请香" message:[NSString stringWithFormat:@"请三支%@，需花费%@",[self.nameArray objectAtIndex:indexPath.row],yuanStr] preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
			UIAlertAction *ok1Action = [UIAlertAction actionWithTitle:@"确认"style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
				[SVProgressHUD showWithStatus:@"请稍候..."];
                if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"平安香"]){
                    [self payAction:@"com.foapp.xuefoqifu.1"];
                    self->_tempStr = @"com.foapp.xuefoqifu.1";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"高升香"]){
                    [self payAction:@"com.foapp.xuefoqifu.1gs"];
                    self->_tempStr = @"com.foapp.xuefoqifu.1gs";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"祈福香"]){
                    [self payAction:@"com.foapp.xuefoqifu.1qf"];
                    self->_tempStr = @"com.foapp.xuefoqifu.1qf";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"鸿运香"]){
                    [self payAction:@"com.foapp.xuefoqifu.6hy"];
                    self->_tempStr = @"com.foapp.xuefoqifu.6hy";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"长寿香"]){
                    [self payAction:@"com.foapp.xuefoqifu.6cs"];
                    self->_tempStr = @"com.foapp.xuefoqifu.6cs";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"就业香"]){
                    [self payAction:@"com.foapp.xuefoqifu.6jy"];
                    self->_tempStr = @"com.foapp.xuefoqifu.6jy";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"姻缘高香"]){
                    [self payAction:@"com.foapp.xuefoqifu.18yy"];
                    self->_tempStr = @"com.foapp.xuefoqifu.18yy";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"求子高香"]){
                    [self payAction:@"com.foapp.xuefoqifu.18qz"];
                    self->_tempStr = @"com.foapp.xuefoqifu.18qz";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"去病高香"]){
                    [self payAction:@"com.foapp.xuefoqifu.18qb"];
                    self->_tempStr = @"com.foapp.xuefoqifu.18qb";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"学业高香"]){
                    [self payAction:@"com.foapp.xuefoqifu.18"];
                    self->_tempStr = @"com.foapp.xuefoqifu.18";
                }else if([[self.nameArray objectAtIndex:indexPath.row] isEqualToString:@"大圆满香"]){
                    [self payAction:@"com.foapp.xuefoqifu.68"];
                    self->_tempStr = @"com.foapp.xuefoqifu.68";
                }
                
//				APPALL.myIAPDelegate = self;
//				self.nowIndex = (int)indexPath.row + 1;
//				NSString *iapID = [tooles getIAPIDByPriceStr:yuanStr payKind:EPayXH];
//				[APPALL startToIAP:iapID];
//                [self.navigationController popViewControllerAnimated:YES];
			}];
			[vc addAction:ok1Action];
			[vc addAction:cancelAction];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self presentViewController:vc animated:YES completion:nil];
			});
		}
			break;
	}
}

-(void)payAction:(NSString *)pid{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    if([SKPaymentQueue canMakePayments]){
        [self requestProductData:pid];
    }else{
        NSLog(@"不允许程序内付费");
    }
}

- (void)VCIAPSucceed:(NSString*)aSucc{
	[SVProgressHUD dismiss];
//	AVQuery *query = [AVQuery queryWithClassName:@"MainTable"];
//	[query whereKey:@"xiangid" equalTo:[NSNumber numberWithInt:self.nowIndex]];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//		if (!error && objects.count) {
//			AVObject *object = [objects firstObject];
//			[object incrementKey:@"xiangnum"];
//			[object saveInBackground];
//		} else {
//		}
//	}];
	
	APPALL.myLocalItem.xiangkind = self.nowIndex;
	APPALL.myLocalItem.xiangtime = [NSDate date];
	[APPALL.myLocalItem saveToDB];
	NSString *msg = [NSString stringWithFormat:@"请%@三支，持续24小时。",[self.nameArray objectAtIndex:APPALL.myLocalItem.xiangkind - 1]];
	UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请香成功" message:msg preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
		[self.navigationController popViewControllerAnimated:YES];
	}];
	[vc addAction:cancelAction];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self presentViewController:vc animated:YES completion:nil];
	});
}

- (void)VCIAPFailed:(NSString*)aSucc{
	[SVProgressHUD dismiss];
	UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:aSucc preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
	[vc addAction:cancelAction];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self presentViewController:vc animated:YES completion:nil];
	});
}


#pragma Pay

//去苹果服务器请求商品
- (void)requestProductData:(NSString *)type{
    
    NSArray *product = [[NSArray alloc] initWithObjects:type,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    if(product.count==0){
//        [WHToast showMessage:@"查找不到商品信息"  duration:1 finishHandler:^{
//        }];
        return;
    }
//    [IHUtility addWaitingView:@"支付中"];
    SKProduct *p = nil;
    for(SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString: _tempStr]){
            p = pro;
        }
    }
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
//    [IHUtility removeWaitingView];
//    [WHToast showMessage:@"支付失败"  duration:1 finishHandler:^{
//    }];
}

- (void)requestDidFinish:(SKRequest *)request{
//    [IHUtility removeWaitingView];
}

//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
//    [IHUtility removeWaitingView];
    for(SKPaymentTransaction *tran in transaction){
        [self verifyPurchaseWithPaymentTransaction:[NSNumber numberWithInt:tran.transactionState]];
        switch(tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{//购买完成
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"buyed"];
                
                APPALL.myLocalItem.xiangkind = self.nowIndex;
                APPALL.myLocalItem.xiangtime = [NSDate date];
                [APPALL.myLocalItem saveToDB];
//                NSString *msg = [NSString stringWithFormat:@"请%@三支，持续24小时。",
//                                 [self.nameArray objectAtIndex:APPALL.myLocalItem.xiangkind - 1]];
//                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"支付成功" message:msg preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//                    [self.navigationController popViewControllerAnimated:YES];
//                    [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                }];
//                [vc addAction:cancelAction];
                //                dispatch_async(dispatch_get_main_queue(), ^{
                //                    [self presentViewController:vc animated:YES completion:nil];
                //                });
//                NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                NSString *idfv = [UUID getUUID];
                BmobQuery   *bquery2 = [BmobQuery queryWithClassName:@"AppInfo"];
                
                [bquery2 whereKey:@"UNIC" equalTo:idfv];
                
                
                
                [bquery2 findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                    NSInteger addCount;
                    for (BmobObject *b in array) {
                        NSInteger gd = [[b objectForKey:@"GongDeCounts"] integerValue];
                        if([self.tempStr containsString:@"1"]&&![self.tempStr containsString:@"18"]){
                            gd+=10;
                            addCount = 10;
                        }else if ([self.tempStr containsString:@"6"]&&![self.tempStr containsString:@"68"]){
                            gd+=65;
                            addCount = 65;
                        }else if ([self.tempStr containsString:@"18"]){
                            gd+=200;
                            addCount = 200;
                        }else if ([self.tempStr containsString:@"68"]){
                            gd+=800;
                            addCount = 800;
                        }
                        
                        [b setObject:[NSNumber numberWithInteger:gd] forKey:@"GongDeCounts"];
                        [b updateInBackground];
                    }
                    
                    BmobObject *b = [BmobObject objectWithClassName:@"ShaoXiang"];
                    [b setObject:idfv forKey:@"UNIC"];
                    if([self.tempStr containsString:@"1"]&&![self.tempStr containsString:@"18"]){
                        [b setObject:@"1" forKey:@"XHWorth"];
                    }else if ([self.tempStr containsString:@"6"]&&![self.tempStr containsString:@"68"]){
                        [b setObject:@"6" forKey:@"XHWorth"];
                    }else if ([self.tempStr containsString:@"18"]){
                        [b setObject:@"18" forKey:@"XHWorth"];
                    }else if ([self.tempStr containsString:@"68"]){
                        [b setObject:@"68" forKey:@"XHWorth"];
                    }
                    
                    [b saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                        [SVProgressHUD dismiss];
                        if(isSuccessful){
                            NSString *msg = [NSString stringWithFormat:@"请%@三支，持续24小时。获取功德+%ld",
                                             [self.nameArray objectAtIndex:APPALL.myLocalItem.xiangkind - 1],addCount];;
                            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请香成功" message:msg preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                [self.navigationController popToRootViewControllerAnimated:true];
                            }];
                            [vc addAction:cancelAction];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentViewController:vc animated:YES completion:nil];
                                _isEarn = false;
                            });
                        }
                    }];
                }];
                
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateRestored:{
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                
//                [WHToast showMessage:@"购买失败"  duration:1 finishHandler:^{
//                }];
                
                [SVProgressHUD dismiss];
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"支付失败" message:@"支付失败，请重试" preferredStyle:UIAlertControllerStyleAlert];
                               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                  [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                               }];
                               [vc addAction:cancelAction];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [self presentViewController:vc animated:YES completion:nil];
                               });
            }
                break;
            default:
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}


- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)verifyPurchaseWithPaymentTransaction:(NSNumber*)resultState{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
}

@end

