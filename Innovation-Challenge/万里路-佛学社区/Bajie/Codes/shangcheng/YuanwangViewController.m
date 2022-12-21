//
//  YuanwangViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/9/25.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "YuanwangViewController.h"
#import <FlatUIKit.h>
//#import <UITextView+Placeholder/UITextView+Placeholder.h>
#import <SVProgressHUD.h>
#import "AppDelegate.h"
#import "MOFSPickerManager.h"
#import "FotaiVController.h"
#import "HWDownSelectedView.h"
#import <Masonry.h>
#import "tooles.h"
@interface YuanwangViewController ()<UITextViewDelegate, HWDownSelectedViewDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property(nonatomic,assign) int xiangIndex;
@property(nonatomic,strong) FotaiVController *foViewController;
@property(nonatomic,assign) CGFloat fotaiWidth;
@property(nonatomic,strong) UILabel *foLabel;
@property(nonatomic,strong) HWDownSelectedView *foDropDown;

@property(nonatomic,strong) FUIButton *xiangButton1;
@property(nonatomic,strong) FUIButton *xiangButton2;
@property(nonatomic,strong) FUIButton *xiangButton3;
@property(nonatomic,strong) FUIButton *xiangButton4;

@property(nonatomic,strong) NSString *bigwish;
@property(nonatomic,strong) NSString *smallwish;
@property(nonatomic,assign) NSInteger luck_no;

@property(nonatomic,strong) FUIButton *kindButton;
@property(nonatomic,strong) UITextView *contentField;

@end
//OK,finally the last xib file to remove.
@implementation YuanwangViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"祈福处";
		self.view.backgroundColor = MMColorYellow;
		
		self.bigwish = @"";
		self.smallwish = @"";
		self.luck_no = 0;
		self.xiangIndex = 0;
		
		self.fotaiWidth = kDeviceWidth;
		self.foViewController = [[FotaiVController alloc] initWithFoName:@"药师佛"
																													andXiangID:self.xiangIndex
																												andVoterName:APPALL.myUserItem.username
																														andKunit:self.fotaiWidth];
		[self.view addSubview:self.foViewController.view];
		
		self.foLabel = [UILabel new];
		self.foLabel.numberOfLines = 0;
		self.foLabel.textAlignment = NSTextAlignmentLeft;
		self.foLabel.text = @"佛像选择:";
		self.foLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
		[self.view addSubview:self.foLabel];
		
		self.foDropDown = [HWDownSelectedView new];
		self.foDropDown.placeholder = @"请选择";
		self.foDropDown.layer.borderWidth = 1;
		self.foDropDown.layer.borderColor = [UIColor blackColor].CGColor;
		self.foDropDown.backgroundColor = MMColorGrey;
		self.foDropDown.font = [UIFont flatFontOfSize:12.0f];
		[self.foDropDown setText:@"药师佛"];
		self.foDropDown.delegate = self;
		self.foDropDown.listArray = @[@"药师佛",@"释迦牟尼佛",@"阿弥陀佛",@"普贤菩萨",@"文殊师利菩萨",@"观世音菩萨",@"地藏王菩萨",@"弥勒尊佛",@"准提菩萨",@"大势至菩萨",@"宝胜如来",@"拘留孙佛",@"韦驮菩萨",@"毗卢遮那佛",@"南无尸弃佛"];
		[self.view addSubview:self.foDropDown];
		
		self.xiangButton1 = [FUIButton new];
		self.xiangButton1.buttonColor = MMColorRed;
		self.xiangButton1.shadowColor = MMColorShadowRed;
		self.xiangButton1.shadowHeight = 2.0f;
		self.xiangButton1.cornerRadius = 2.0f;
		self.xiangButton1.tag = 1;
		self.xiangButton1.titleLabel.font = [UIFont boldFlatFontOfSize:14];
		[self.xiangButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.xiangButton1 setTitle:@"供香" forState:UIControlStateNormal];
		[self.xiangButton1 addTarget:self action:@selector(xiangPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:self.xiangButton1];
		
		self.xiangButton2 = [FUIButton new];
		self.xiangButton2.buttonColor = MMColorRed;
		self.xiangButton2.shadowColor = MMColorShadowRed;
		self.xiangButton2.shadowHeight = 2.0f;
		self.xiangButton2.cornerRadius = 2.0f;
		self.xiangButton2.tag = 2;
		self.xiangButton2.titleLabel.font = [UIFont boldFlatFontOfSize:14];
		[self.xiangButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.xiangButton2 setTitle:@"供花" forState:UIControlStateNormal];
		[self.xiangButton2 addTarget:self action:@selector(xiangPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:self.xiangButton2];
		
		self.xiangButton3 = [FUIButton new];
		self.xiangButton3.buttonColor = MMColorRed;
		self.xiangButton3.shadowColor = MMColorShadowRed;
		self.xiangButton3.shadowHeight = 2.0f;
		self.xiangButton3.cornerRadius = 2.0f;
		self.xiangButton3.tag = 3;
		self.xiangButton3.titleLabel.font = [UIFont boldFlatFontOfSize:14];
		[self.xiangButton3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.xiangButton3 setTitle:@"供果" forState:UIControlStateNormal];
		[self.xiangButton3 addTarget:self action:@selector(xiangPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:self.xiangButton3];
		
		self.xiangButton4 = [FUIButton new];
		self.xiangButton4.buttonColor = MMColorRed;
		self.xiangButton4.shadowColor = MMColorShadowRed;
		self.xiangButton4.shadowHeight = 2.0f;
		self.xiangButton4.cornerRadius = 2.0f;
		self.xiangButton4.tag = 4;
		self.xiangButton4.titleLabel.font = [UIFont boldFlatFontOfSize:14];
		[self.xiangButton4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.xiangButton4 setTitle:@"供水" forState:UIControlStateNormal];
		[self.xiangButton4 addTarget:self action:@selector(xiangPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:self.xiangButton4];
		
		self.kindButton = [FUIButton new];
		self.kindButton.buttonColor = MMColorRed;
		self.kindButton.shadowColor = MMColorShadowRed;
		self.kindButton.shadowHeight = 3.0f;
		self.kindButton.cornerRadius = 3.0f;
		self.kindButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
		[self.kindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.kindButton setTitle:@"选择祈福类型" forState:UIControlStateNormal];
		[self.kindButton addTarget:self action:@selector(kindPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:self.kindButton];
		
		self.contentField = [UITextView new];
		self.contentField.backgroundColor = [UIColor clearColor];
		self.contentField.font = [UIFont fontWithName:@"Arial" size:16.0f];
		self.contentField.returnKeyType = UIReturnKeyDone;
		self.contentField.delegate = self;
		self.contentField.textColor = [UIColor blackColor];
		self.contentField.text = @"写下您的祈福内容，限制200个字。";
//		self.contentField.placeholderColor = [UIColor grayColor];
		self.contentField.layer.borderWidth = 2.0f;
		self.contentField.layer.borderColor = MMColorBlack.CGColor;
		[self.view addSubview:self.contentField];
		
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(xyPressed:)];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	WS(ws);
	
	[self.foViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(ws.view.mas_left);
		make.top.mas_equalTo(ws.view);
	}];
	
	[self.foLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(110, 20));
		make.left.mas_equalTo(ws.view).with.offset(10);
		make.top.mas_equalTo(ws.view).with.offset(10);
	}];
	
	[self.foDropDown mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake(110, 25));
		make.left.mas_equalTo(ws.view).with.offset(10);
		make.top.mas_equalTo(ws.foLabel.mas_bottom).with.offset(5);
	}];
	
	[self.xiangButton1 mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake((kDeviceWidth - 40)/4, 25));
		make.left.mas_equalTo(ws.view).with.offset(5);
		make.top.mas_equalTo(ws.view).with.offset(ws.fotaiWidth * 468/566 + 5);
	}];
	
	[self.xiangButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake((kDeviceWidth - 40)/4, 25));
		make.left.mas_equalTo(ws.xiangButton1.mas_right).with.offset(10);
		make.top.mas_equalTo(ws.xiangButton1);
	}];
	
	[self.xiangButton3 mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake((kDeviceWidth - 40)/4, 25));
		make.left.mas_equalTo(ws.xiangButton2.mas_right).with.offset(10);
		make.top.mas_equalTo(ws.xiangButton2);
	}];
	
	[self.xiangButton4 mas_makeConstraints:^(MASConstraintMaker *make) {
		make.size.mas_equalTo(CGSizeMake((kDeviceWidth - 40)/4, 25));
		make.left.mas_equalTo(ws.xiangButton3.mas_right).with.offset(10);
		make.top.mas_equalTo(ws.xiangButton3);
	}];
	
	[self.kindButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(ws.view).with.offset(5);
		make.right.mas_equalTo(ws.view).with.offset(-5);
		make.top.mas_equalTo(ws.xiangButton1.mas_bottom).with.offset(10);
		make.height.mas_equalTo(30);
	}];
	
	[self.contentField mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(ws.kindButton.mas_left);
		make.right.mas_equalTo(ws.kindButton.mas_right);
		make.top.mas_equalTo(ws.kindButton.mas_bottom).with.offset(10);
		make.bottom.mas_equalTo(ws.view).with.offset(-10);
	}];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@"写下您的祈福内容，限制200个字。"]){
        textView.text = @"";
    }
}
-(BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
	if([text isEqualToString:@"\n"]){
		[textView resignFirstResponder];
		return NO;
	}
	return YES;
}

-(void)xyPressed:(id)sender{
	if(!self.contentField.text.length){
        
		[SVProgressHUD setMinimumDismissTimeInterval:2.0f];
		[SVProgressHUD showInfoWithStatus:@"愿望不能为空，否则空欢喜一场！"];
		return;
    }else{
        if([self.contentField.text isEqual:@"写下您的祈福内容，限制200个字。"]){
            [SVProgressHUD setMinimumDismissTimeInterval:2.0f];
            [SVProgressHUD showInfoWithStatus:@"愿望不能为空，否则空欢喜一场！"];
            return;
        }
    }
	if(!self.bigwish.length || !self.smallwish.length){
		[SVProgressHUD setMinimumDismissTimeInterval:2.0f];
		[SVProgressHUD showInfoWithStatus:@"请选择最适合的许愿类型！"];
		return;
	}
//	UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确认祈福" message:@"祈福需心怀肃穆，许愿后无法删除或撤回，确认提交吗？" preferredStyle:UIAlertControllerStyleAlert];
//	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//	UIAlertAction *ok1Action = [UIAlertAction actionWithTitle:@"确认"style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//		[self saveWish];
//        [self.navigationController popViewControllerAnimated:true];
//	}];
//	[vc addAction:ok1Action];
//	[vc addAction:cancelAction];
//	dispatch_async(dispatch_get_main_queue(), ^{
//		[self presentViewController:vc animated:YES completion:nil];
//	});
    [self payBack];
}

-(void)xiangPressed:(id)sender {
	NSLog(@"%ld", [sender tag]);
	self.xiangIndex = (int)[sender tag] - 1;
	[self.foViewController setXiangID:self.xiangIndex];
}

//-(void)moneyPressed:(id)sender {
//    //8,18,50,88,138,198,268,588
//    NSArray * arr = [NSArray arrayWithObjects:@"0功德",@"8功德",@"18功德",@"50功德",@"88功德",@"138功德",@"198功德",@"268功德",@"588功德",nil];
//    if(dropDown == nil) {
//        CGFloat f = 225;
//        dropDown = [[NIDropDown alloc] showDropDown:sender :&f :arr :nil :@"down"];
//        dropDown.delegate = self;
//    }
//    else {
//        [dropDown hideDropDown:sender];
//        [self rel];
//    }
//}

-(void)kindPressed:(id)sender {
	[[MOFSPickerManager shareManger] showMOFSWishTypePickerWithTitle:nil cancelTitle:@"取消" commitTitle:@"完成" commitBlock:^(NSString *bwish, NSString *swish) {
		self.bigwish = bwish;
		self.smallwish = swish;
		[self.kindButton setTitle:[NSString stringWithFormat:@"求：%@-%@",self.bigwish,self.smallwish] forState:UIControlStateNormal];
	} cancelBlock:^{
		
	}];
}

- (void)bgIndex:(NSInteger)bgid {
	self.luck_no = bgid;
	//	[self.bgButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_%li.jpg",self.luck_no]] forState:UIControlStateNormal];
}

-(void)saveWish {
//	AVObject *todoFolder = [[AVObject alloc] initWithClassName:@"WishTree"];
//	[todoFolder setObject:APPALL.myUserItem.username forKey:@"username"];1
//	[todoFolder setObject:self.contentField.text forKey:@"content"];2
//	[todoFolder setObject:[NSString stringWithFormat:@"%@-%@", self.bigwish, self.smallwish] forKey:@"title"];3
//	[todoFolder setObject:[NSNumber numberWithInt:self.xiangIndex] forKey:@"xiangid"];4
//	[todoFolder setObject:self.foDropDown.text forKey:@"foname"];5
//	[todoFolder setObject:self.bigwish forKey:@"bigwish"];6
//	[todoFolder setObject:self.smallwish forKey:@"smallwish"];
//	//    NSString *goldstr = [self.moneyButton titleForState:UIControlStateNormal];
//	//    int goldnum = [[goldstr substringToIndex:goldstr.length - 1] intValue];
//	int goldnum = 0;
//	[todoFolder setObject:[NSNumber numberWithInt:goldnum] forKey:@"gold"];
//	NSDate *saveDate = [NSDate dateWithTimeIntervalSinceNow:goldnum * 86400];
//	[todoFolder setObject:saveDate forKey:@"wishdate"];
//	[todoFolder saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//		if(succeeded){
//			UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"许愿成功" message:@"恭喜您许愿成功！" preferredStyle:UIAlertControllerStyleAlert];
//			UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//				[self.navigationController popViewControllerAnimated:YES];
//			}];
//			[vc addAction:cancelAction];
//			dispatch_async(dispatch_get_main_queue(), ^{
//				[self presentViewController:vc animated:YES completion:nil];
//			});
//		}else{
//			[SVProgressHUD showErrorWithStatus:@"许愿失败，请查看您的网络。"];
//		}
//	}];
        //    NSString *goldstr = [self.moneyButton titleForState:UIControlStateNormal];
        //    int goldnum = [[goldstr substringToIndex:goldstr.length - 1] intValue];
        int goldnum = 0;
    NSUserDefaults *dd = [NSUserDefaults standardUserDefaults];
    NSMutableArray *a = [NSMutableArray arrayWithArray:[dd objectForKey:@"qifuArray"]];
    NSString *s = APPALL.myUserItem.username;
    if(APPALL.myUserItem.username == nil || [APPALL.myUserItem.username isEqual:@""]){
        s = @"香客";
    }
    NSMutableDictionary *d = [[NSMutableDictionary alloc]initWithObjectsAndKeys:s,@"username",self.contentField.text,@"content",[NSString stringWithFormat:@"%@-%@", self.bigwish, self.smallwish],@"title",[NSNumber numberWithInt:self.xiangIndex],@"xiangid",self.foDropDown.text,@"foname",self.bigwish,@"bigwish",self.smallwish,@"smallwish",[NSNumber numberWithInt:goldnum],@"gold",[NSDate dateWithTimeIntervalSinceNow:goldnum * 86400],@"wishdate", nil];
    if (a){
        [a addObject:d];
    }else{
        a = [NSMutableArray new];
        [a addObject:d];
    }
    [dd setObject:a forKey:@"qifuArray"];
    [dd synchronize];
}

//- (void)VCIAPSucceed:(NSString*)aSucc{
//	[SVProgressHUD dismiss];
//	[self saveWish];
//}
//
//- (void)VCIAPFailed:(NSString*)aSucc{
//	[SVProgressHUD dismiss];
//	UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:aSucc preferredStyle:UIAlertControllerStyleAlert];
//	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
//	[vc addAction:cancelAction];
//	dispatch_async(dispatch_get_main_queue(), ^{
//		[self presentViewController:vc animated:YES completion:nil];
//	});
//}

-(void)payAction:(NSString *)pid{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    if([SKPaymentQueue canMakePayments]){
        [self requestProductData:pid];
    }else{
        NSLog(@"不允许程序内付费");
    }
}


-(void)payBack{
   
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"许愿" message:[NSString stringWithFormat:@"许愿前请确认好许愿内容，许愿需心怀肃穆，许愿后无法删除或撤回，确认花费6元提交许愿内容吗？"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *ok1Action = [UIAlertAction actionWithTitle:@"确认"style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [SVProgressHUD showWithStatus:@"请稍候..."];
                    [self payAction:@"com.foapp.xuefoqifu.6xy"];
                    
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
        
        if([pro.productIdentifier isEqualToString: @"com.foapp.xuefoqifu.6xy"]){
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
                
//                NSUserDefaults *ss = [NSUserDefaults standardUserDefaults];
//                NSMutableArray *a = [NSMutableArray arrayWithArray:[ss objectForKey:@"qifuArray"]];
//                NSMutableDictionary *s = [NSMutableDictionary dictionaryWithDictionary:a[self->_numArray]];
//                [s setValue:@"OK" forKey:@"isPay"];
//                [a removeObjectAtIndex:self->_numArray];
//                [a addObject:s];
//                [ss setValue:a forKey:@"qifuArray"];
//                [ss synchronize];
//                                [self.listView reloadData];
//                [self.completBtn setTitle:@"已还愿" forState:UIControlStateNormal];
//                [self.completBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//                self.completBtn.layer.borderColor = [UIColor grayColor].CGColor;
//                self.completBtn.userInteractionEnabled = false;
//
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"恭喜您，您已成功许愿。愿您心想事成,福慧双增,破除烦恼,法喜充满,吉祥如意"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self saveWish];
                    [self.navigationController popViewControllerAnimated:true];
                }];
                                       [vc addAction:cancelAction];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self presentViewController:vc animated:YES completion:nil];
                                       });
//
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


- (void)downSelectedView:(HWDownSelectedView *)selectedView didSelectedAtIndex:(NSIndexPath *)indexPath {
	NSLog(@"%ld, %@", indexPath.row, selectedView.listArray[indexPath.row]);
	[self.foViewController setFoName:selectedView.listArray[indexPath.row]];
}

@end
