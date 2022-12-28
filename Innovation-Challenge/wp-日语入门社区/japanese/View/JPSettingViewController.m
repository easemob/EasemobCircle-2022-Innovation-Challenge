//
//  JPCheckViewController.m
//  japanese
//
//  Created by LYQ on 2021/2.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "JPSettingViewController.h"
#import <SVProgressHUD.h>
#import "AboutsViewController.h"
@import GoogleMobileAds;
@interface JPSettingViewController()<UITableViewDelegate,UITableViewDataSource>
//@property(nonatomic,copy)NSString *tempStr;
@property(nonatomic, strong) GADBannerView *bannerView;
@end

@implementation JPSettingViewController{
    UITableView *settingTableView;
    NSArray *settingArray;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"设置";
    settingArray = @[@"关于我们",@"给我好评"];
    settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,StartY, self.view.frame.size.width, self.view.frame.size.height-StartY-TabBarHeight) style:UITableViewStylePlain];
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    [settingTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:settingTableView];
//    settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    settingTableView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    [settingTableView setTableFooterView:[[UIView alloc] init]];//去掉多余横线
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    
    // In this case, we instantiate the banner with desired ad size.
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
     self.bannerView = [[GADBannerView alloc]
         initWithAdSize:kGADAdSizeBanner];

     [self addBannerViewToView:self.bannerView];
    self.bannerView.adUnitID = @"ca-app-pub-9139925389247586/3453235364";
      self.bannerView.rootViewController = self;
      [self.bannerView loadRequest:[GADRequest request]];
   }

   - (void)addBannerViewToView:(UIView *)bannerView {
     bannerView.translatesAutoresizingMaskIntoConstraints = NO;
     [self.view addSubview:bannerView];
     [self.view addConstraints:@[
       [NSLayoutConstraint constraintWithItem:bannerView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.bottomLayoutGuide
                                  attribute:NSLayoutAttributeTop
                                 multiplier:1
                                   constant:0],
       [NSLayoutConstraint constraintWithItem:bannerView
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1
                                   constant:0]
                                   ]];
   }


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
//        [self showPayAlert];
        [self.navigationController pushViewController:[AboutsViewController new] animated:true];
    }else if(indexPath.row == 1){
        NSURL *s = [NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/id1551810853?mt=8&action=write-review"];
        [[UIApplication sharedApplication] openURL:s options:@[] completionHandler:nil];
    }
}

//-(void)showPayAlert{
//    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"感谢您的打赏～" message:@"请选择打赏金额" preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *b = [UIAlertAction actionWithTitle:@"1元" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [SVProgressHUD showWithStatus:@"请稍候..."];
//        [self payAction:@"com.japan.50words.1pay"];
//        self->_tempStr = @"com.japan.50words.1pay";
//    }];
//    UIAlertAction *c = [UIAlertAction actionWithTitle:@"6元" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [SVProgressHUD showWithStatus:@"请稍候..."];
//        [self payAction:@"com.japan.50words.6pay"];
//        self->_tempStr = @"com.japan.50words.6pay";
//    }];
//    UIAlertAction *d = [UIAlertAction actionWithTitle:@"18元" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [SVProgressHUD showWithStatus:@"请稍候..."];
//        [self payAction:@"com.japan.50words.18pay"];
//        self->_tempStr = @"com.japan.50words.18pay";
//    }];
//    UIAlertAction *e = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [a addAction:b];
//    [a addAction:c];
//    [a addAction:d];
//    [a addAction:e];
//    [self presentViewController:a animated:true completion:nil];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return settingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [settingArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"setting"];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//-(void)payAction:(NSString *)pid{
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    if([SKPaymentQueue canMakePayments]){
//        [self requestProductData:pid];
//    }else{
//        NSLog(@"不允许程序内付费");
//    }
//}
//
//#pragma Pay
//
////去苹果服务器请求商品
//- (void)requestProductData:(NSString *)type{
//    
//    NSArray *product = [[NSArray alloc] initWithObjects:type,nil];
//    NSSet *nsset = [NSSet setWithArray:product];
//    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
//    request.delegate = self;
//    [request start];
//}
//
////收到产品返回信息
//- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
//    
//    NSLog(@"--------------收到产品反馈消息---------------------");
//    NSArray *product = response.products;
//    NSLog(@"productID:%@", response.invalidProductIdentifiers);
//    if(product.count==0){
////        [WHToast showMessage:@"查找不到商品信息"  duration:1 finishHandler:^{
////        }];
//        return;
//    }
////    [IHUtility addWaitingView:@"支付中"];
//    SKProduct *p = nil;
//    for(SKProduct *pro in product) {
//        NSLog(@"%@", [pro description]);
//        NSLog(@"%@", [pro localizedTitle]);
//        NSLog(@"%@", [pro localizedDescription]);
//        NSLog(@"%@", [pro price]);
//        NSLog(@"%@", [pro productIdentifier]);
//        
//        if([pro.productIdentifier isEqualToString: _tempStr]){
//            p = pro;
//        }
//    }
//    SKPayment *payment = [SKPayment paymentWithProduct:p];
//    NSLog(@"发送购买请求");
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
//}
//
////请求失败
//- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
////    [IHUtility removeWaitingView];
////    [WHToast showMessage:@"支付失败"  duration:1 finishHandler:^{
////    }];
//}
//
//- (void)requestDidFinish:(SKRequest *)request{
////    [IHUtility removeWaitingView];
//}
//
////监听购买结果
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
////    [IHUtility removeWaitingView];
//    for(SKPaymentTransaction *tran in transaction){
//        [self verifyPurchaseWithPaymentTransaction:[NSNumber numberWithInt:tran.transactionState]];
//        switch(tran.transactionState) {
//            case SKPaymentTransactionStatePurchased:{//购买完成
//                [SVProgressHUD dismiss];
////                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"buyed"];
////                
////                APPALL.myLocalItem.xiangkind = self.nowIndex;
////                APPALL.myLocalItem.xiangtime = [NSDate date];
////                [APPALL.myLocalItem saveToDB];
////                NSString *msg = [NSString stringWithFormat:@"请%@三支，持续24小时。",
////                                 [self.nameArray objectAtIndex:APPALL.myLocalItem.xiangkind - 1]];
//                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"支付成功" message:@"非常感谢您的打赏与支持，我们将继续努力完善每一个功能，" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//                    [self.navigationController popViewControllerAnimated:YES];
//                    [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                }];
//                [vc addAction:cancelAction];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self presentViewController:vc animated:YES completion:nil];
//                });
//            
//            }
//                break;
//            case SKPaymentTransactionStatePurchasing:
//                break;
//            case SKPaymentTransactionStateRestored:{
//                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//            }
//                break;
//            case SKPaymentTransactionStateFailed:{
//                
////                [WHToast showMessage:@"购买失败"  duration:1 finishHandler:^{
////                }];
//                
//                [SVProgressHUD dismiss];
//                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"支付失败" message:@"非常感谢你的打赏！但是支付失败噢，如果可以请请重试吧～" preferredStyle:UIAlertControllerStyleAlert];
//                               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//                                  [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                               }];
//                               [vc addAction:cancelAction];
//                               dispatch_async(dispatch_get_main_queue(), ^{
//                                   [self presentViewController:vc animated:YES completion:nil];
//                               });
//            }
//                break;
//            default:
//                break;
//        }
//    }
//}
//
////交易结束
//- (void)completeTransaction:(SKPaymentTransaction *)transaction{
//    NSLog(@"交易结束");
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    
//}
//
//
//- (void)dealloc{
//    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
//}
//
//-(void)verifyPurchaseWithPaymentTransaction:(NSNumber*)resultState{
//    //从沙盒中获取交易凭证并且拼接成请求体数据
//    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
//    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
//}


@end
