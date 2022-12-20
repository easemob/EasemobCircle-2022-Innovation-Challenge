//
//  YuanDetailViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 2018/2/25.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "YuanDetailViewController.h"
#import "FotaiVController.h"
#import <SVProgressHUD.h>
#import "AppDelegate.h"
#import "tooles.h"
#import <FlatUIKit.h>
#import <Masonry.h>

@interface YuanDetailViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property(nonatomic,strong) FotaiVController *foViewController;
@property(nonatomic,assign) CGFloat fotaiWidth;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UITextView *contentField;
@property(nonatomic,strong) UILabel *dateLabel;
@property(nonatomic,strong) UILabel *moneyLabel;

@end

@implementation YuanDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//	if (self) {
		self.view.frame = CGRectMake(0, 0, kDeviceWidth * 0.875, KDeviceHeight * 0.75);
		self.view.backgroundColor = MMColorOrange;
		
		self.fotaiWidth = kDeviceWidth * 0.875;
		self.foViewController = [[FotaiVController alloc] initWithFoName:@""
																													andXiangID:0
																												andVoterName:@""
																														andKunit:self.fotaiWidth];
		[self.view addSubview:self.foViewController.view];
		
		self.titleLabel = [UILabel new];
		self.titleLabel.textColor = [UIColor blackColor];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		self.titleLabel.font = [UIFont fontWithName:@"Arial" size:16.0f];
		[self.view addSubview:self.titleLabel];
		
		self.dateLabel = [UILabel new];
		self.dateLabel.textColor = [UIColor grayColor];
		self.dateLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
		self.dateLabel.textAlignment = NSTextAlignmentRight;
		[self.view addSubview:self.dateLabel];
		
		self.moneyLabel = [UILabel new];
		self.moneyLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
		self.moneyLabel.textAlignment = NSTextAlignmentLeft;
		[self.view addSubview:self.moneyLabel];
        
        self.completBtn = [UIButton new];
        [self.completBtn setTitle:@"我要还愿" forState:UIControlStateNormal];
        [self.completBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.completBtn.backgroundColor = mainColor;
        self.completBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        self.completBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        self.completBtn.layer.borderWidth = 1.0;
        [self.completBtn addTarget:self action:@selector(payBack) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.completBtn];
		
		self.contentField = [UITextView new];
        
        if([self.contentField.text length]>0)
        {
            //contentField的contentSize属性
            CGSize contentSize = self.contentField.contentSize;
            //contentField的内边距属性
            UIEdgeInsets offset;
            CGSize newSize = contentSize;
            
            //如果文字内容高度没有超过contentField的高度
            if(contentSize.height <= self.contentField.frame.size.height)
            {
                //contentField的高度减去文字高度除以2就是Y方向的偏移量，也就是contentField的上内边距
                CGFloat offsetY = (self.contentField.frame.size.height - contentSize.height)/2;
                offset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
            }
            else          //如果文字高度超出contentField的高度
            {
                newSize = self.contentField.frame.size;
                offset = UIEdgeInsetsZero;
                CGFloat fontSize = 18;

               //通过一个while循环，设置contentField的文字大小，使内容不超过整个contentField的高度（这个根据需要可以自己设置）
                while (contentSize.height > self.contentField.frame.size.height)
                {
                    [self.contentField setFont:[UIFont fontWithName:@"Helvetica Neue" size:fontSize--]];
                    contentSize = self.contentField.contentSize;
                }
                newSize = contentSize;
            }
            
            //根据前面计算设置contentField的ContentSize和Y方向偏移量
            [self.contentField setContentSize:newSize];
            [self.contentField setContentInset:offset];
            
        }
        self.contentField.contentMode = UIViewContentModeCenter;
		self.contentField.backgroundColor = [UIColor clearColor];
		self.contentField.font = [UIFont fontWithName:@"Arial" size:16.0f];
		self.contentField.textColor = [UIColor darkGrayColor];
		self.contentField.editable = NO;
		self.contentField.selectable = NO;
		[self.view addSubview:self.contentField];
		
//	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	[self.foViewController setFoName:self.myWish[@"foname"]];
	[self.foViewController setXiangID:[self.myWish[@"xiangid"] intValue]];
	[self.foViewController setVoterName:self.myWish[@"username"]];
	
	self.titleLabel.text = self.myWish[@"title"];
	self.contentField.text = self.myWish[@"content"];
    if(self.myWish[@"isPay"] != nil){
        [self.completBtn setTitle:@"已还愿" forState:UIControlStateNormal];
        [self.completBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.completBtn.layer.borderColor = [UIColor grayColor].CGColor;
        self.completBtn.userInteractionEnabled = false;
    }else{
        [self.completBtn setTitle:@"我要还愿" forState:UIControlStateNormal];
        [self.completBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.completBtn.backgroundColor = mainColor;
        self.completBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        self.completBtn.userInteractionEnabled = true;
    }
	NSDate *date = [_myWish objectForKey:@"wishdate"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	self.dateLabel.text = [dateFormatter stringFromDate:date];
	self.moneyLabel.text = [NSString stringWithFormat:@"㉤%d",[self.myWish[@"gold"] intValue]];
	if([self.moneyLabel.text isEqualToString:@"㉤0"]) {
		self.moneyLabel.hidden = YES;
	} else {
		self.moneyLabel.hidden = NO;
	}
	
	WS(ws);
	
	[self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(ws.view.mas_left).with.offset(10);
		make.right.mas_equalTo(ws.view.mas_right).with.offset(-10);
		make.top.mas_equalTo(ws.view.mas_top).with.offset(ws.fotaiWidth * 468/566);
		make.height.mas_equalTo(20);
	}];
	
	[self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(self.titleLabel.mas_left);
		make.right.mas_equalTo(self.titleLabel.mas_right);
		make.bottom.mas_equalTo(ws.view);
		make.height.mas_equalTo(20);
	}];
	
	
    
    [self.completBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
//        make.right.mas_equalTo(self.titleLabel.mas_right);
        make.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(70);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.completBtn.mas_right);
        make.right.mas_equalTo(self.titleLabel.mas_right);
        make.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(20);
    }];
	
	[self.contentField mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(self.titleLabel.mas_left);
		make.right.mas_equalTo(self.titleLabel.mas_right);
		make.top.mas_equalTo(self.titleLabel.mas_bottom);
		make.bottom.mas_equalTo(self.completBtn.mas_top);
	}];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


-(void)payAction:(NSString *)pid{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    if([SKPaymentQueue canMakePayments]){
        [self requestProductData:pid];
    }else{
        NSLog(@"不允许程序内付费");
    }
}


-(void)payBack{
   
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"还愿" message:[NSString stringWithFormat:@"如果您的许愿已经达成，可在此进行还愿（6元）"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *ok1Action = [UIAlertAction actionWithTitle:@"我要还愿"style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [SVProgressHUD showWithStatus:@"请稍候..."];
                    [self payAction:@"com.foapp.xuefoqifu.6xyhy"];
                    
//    NSUserDefaults *ss = [NSUserDefaults standardUserDefaults];
//    NSMutableArray *a = [NSMutableArray arrayWithArray:[ss objectForKey:@"qifuArray"]];
//    NSMutableDictionary *s = [NSMutableDictionary dictionaryWithDictionary:a[self->_numArray]];
//    [s setValue:@"OK" forKey:@"isPay"];
//    [a removeObjectAtIndex:self->_numArray];
//    [a addObject:s];
//    [ss setValue:a forKey:@"qifuArray"];
//    [ss synchronize];
//                    [self.listView reloadData];
//    [self.completBtn setTitle:@"已还愿" forState:UIControlStateNormal];
//    [self.completBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    self.completBtn.layer.borderColor = [UIColor grayColor].CGColor;
//    self.completBtn.userInteractionEnabled = false;
                    
                }];
                [vc addAction:ok1Action];
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
        
        if([pro.productIdentifier isEqualToString: @"com.foapp.xuefoqifu.6xyhy"]){
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
                [SVProgressHUD dismiss];
                NSUserDefaults *ss = [NSUserDefaults standardUserDefaults];
                NSMutableArray *a = [NSMutableArray arrayWithArray:[ss objectForKey:@"qifuArray"]];
                NSMutableDictionary *s = [NSMutableDictionary dictionaryWithDictionary:a[self->_numArray]];
                [s setValue:@"OK" forKey:@"isPay"];
                [a removeObjectAtIndex:self->_numArray];
                [a addObject:s];
                [ss setValue:a forKey:@"qifuArray"];
                [ss synchronize];
                                [self.listView reloadData];
                [self.completBtn setTitle:@"已还愿" forState:UIControlStateNormal];
                [self.completBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                self.completBtn.layer.borderColor = [UIColor grayColor].CGColor;
                self.completBtn.userInteractionEnabled = false;
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"恭喜您，您已成功还愿。愿您福慧双增,破除烦恼,法喜充满,吉祥如意"] preferredStyle:UIAlertControllerStyleAlert];
                               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
                                       [vc addAction:cancelAction];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self presentViewController:vc animated:YES completion:nil];
                                       });
                
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateRestored:{
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
//                [WHToast showMessage:@"购买失败"  duration:1 finishHandler:^{
//                }];
                [SVProgressHUD dismiss];
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"支付失败" message:@"支付失败，请重试" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){

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

