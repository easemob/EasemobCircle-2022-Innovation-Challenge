//
//  DHDetailViewController.m
//  XuefoQiFu
//
//  Created by Mac on 2022/1/26.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import "DHDetailViewController.h"
#import <SVProgressHUD.h>
#import "UUID.h"
@interface DHDetailViewController ()<UIScrollViewDelegate,UITextFieldDelegate>

@end

@implementation DHDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"确认兑换";
    self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 900);
    self.scroller.delegate = self;
//    self.mainImg.image = [self Base64StrToUIImage:[_mainB objectForKey:@"ImageBase"]];
    
    UIImage *img = [UIImage imageNamed:[_mainB objectForKey:@"ImageBase"]];
    if(img){
        self.mainImg.image = img;
    }else{
        self.mainImg.image = [UIImage imageNamed:@"icon_no_place"];
    }
    self.mainImg.layer.borderWidth = 0.5;
    self.mainImg.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.mainTitleLb.text = [NSString stringWithFormat:@"%@",[_mainB objectForKey:@"giftTitle"]];
    self.mainContentTV.text = [NSString stringWithFormat:@"%@(图片仅供参考，以实物为准)",[_mainB objectForKey:@"giftContent"]];
    self.mainContentTV.editable = false;
    self.mainContentTV.layer.borderWidth = 0.5;
    self.mainContentTV.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.mainContentTV.layer.cornerRadius = 5;
    self.addressTf.delegate = self;
    self.addressTf.tag = 1111;
    self.nameTf.delegate = self;
    self.nameTf.tag = 2222;
    self.phoneTf.delegate  = self;
    self.phoneTf.tag = 3333;
    self.phoneTf.keyboardType = UIKeyboardTypePhonePad;
    [self.confirmBtn addTarget:self action:@selector(confirmDH:) forControlEvents:UIControlEventTouchUpInside];
}
-(UIImage *)Base64StrToUIImage:(NSString *)_encodedImageStr

{

    NSData *_decodedImageData   = [[NSData alloc] initWithBase64Encoding:_encodedImageStr];

    UIImage *_decodedImage      = [UIImage imageWithData:_decodedImageData];

    return _decodedImage;

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;   {
    if(textField.tag == 1111){
        self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 1200);
        [self.scroller setContentOffset:CGPointMake(0, 500)];
    }else if(textField.tag == 2222){
        self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 1200);
        [self.scroller setContentOffset:CGPointMake(0, 500)];
    }else if(textField.tag == 3333){
        self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 1200);
        [self.scroller setContentOffset:CGPointMake(0, 500)];
    }else{
        self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 900);
    }
    return true;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if(textField.tag == 1111){
        if(self.scroller.contentSize.height!=1200){
            self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 900);
        }
        
    }else if(textField.tag == 2222){
        if(self.scroller.contentSize.height!=1200){
            self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 900);
        }
    }else if(textField.tag == 3333){
        if(self.scroller.contentSize.height!=1200){
            self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 900);
        }
    }else{
        if(self.scroller.contentSize.height!=1200){
            self.scroller.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 900);
        }
    }
    return true;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;{
    [self.addressTf resignFirstResponder];
    [self.nameTf resignFirstResponder];
    [self.phoneTf resignFirstResponder];
}

-(void)confirmDH:(UIButton *)b{
    if(self.addressTf.text.length<=10){
        [SVProgressHUD showInfoWithStatus:@"请输入您的详细地址(包括省/市/区)"];
        [SVProgressHUD dismissWithDelay:1.5f];
        return;
    }
    
    if(self.nameTf.text.length==0){
        [SVProgressHUD showInfoWithStatus:@"请输入您正确的收货姓名"];
        [SVProgressHUD dismissWithDelay:1.5f];
        return;
    }
    
    if(self.phoneTf.text.length!=11){
        [SVProgressHUD showInfoWithStatus:@"请输入正确的11位数收货手机号码"];
        [SVProgressHUD dismissWithDelay:1.5f];
        return;
    }
    
    //首先判断是否足够
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *idfv = [UUID getUUID];
    BmobQuery   *bquery2 = [BmobQuery queryWithClassName:@"AppInfo"];
    [bquery2 whereKey:@"UNIC" equalTo:idfv];
    [SVProgressHUD show];
    [bquery2 findObjectsInBackgroundWithBlock:^(NSArray *array2, NSError *error) {
        if(error){
            [SVProgressHUD dismiss];
            [SVProgressHUD showWithStatus:error.description];
            [SVProgressHUD dismissWithDelay:1.5f];
        }
        
        for (BmobObject *obj in array2) {
            NSInteger ownGD = [[obj objectForKey:@"GongDeCounts"] integerValue];
            NSInteger shouldPayGD = [[_mainB objectForKey:@"GDPay"] integerValue];
            if(ownGD>=shouldPayGD){
                [obj setObject:[NSNumber numberWithInteger:(ownGD-shouldPayGD)] forKey:@"GongDeCounts"];
                [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if(isSuccessful){
                        
                        //扣除功德成功,生成发货订单
                        BmobObject *gameScore = [BmobObject objectWithClassName:@"Deliver"];
                        [gameScore setObject:[NSString stringWithFormat:@"%ld",shouldPayGD] forKey:@"GDPay"];
                        [gameScore setObject:[obj objectForKey:@"NickName"] forKey:@"NickName"];
                        [gameScore setObject:idfv forKey:@"UNIC"];
                        [gameScore setObject:_mainB.objectId forKey:@"productID"];
                        [gameScore setObject:self.addressTf.text forKey:@"address"];
                        [gameScore setObject:self.nameTf.text forKey:@"name"];
                        [gameScore setObject:self.phoneTf.text forKey:@"phone"];
                        [gameScore setObject:@"0" forKey:@"status"];
                        [gameScore setObject:[_mainB objectForKey:@"giftTitle"] forKey:@"productName"];
                        [gameScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                            if(isSuccessful){
                                //生成订单成功
                                [SVProgressHUD dismiss];
                                [SVProgressHUD showWithStatus:@"兑换成功！我们将在15个工作日内发出（节假日则按日期顺延）"];
                                [SVProgressHUD dismissWithDelay:2.0f];
                                [self.navigationController popToRootViewControllerAnimated:true];
                            }else{
                                [SVProgressHUD dismiss];
//                                [SVProgressHUD showWithStatus:@"出现意外错误，请联系QQ：2513505027，我们将对您进行补发"];
//                                [SVProgressHUD dismissWithDelay:4.0f];
                                [obj setObject:@"error" forKey:@"isError"];
                                [obj updateInBackground];
                                UIAlertController *a = [UIAlertController alertControllerWithTitle:@"提示" message:@"出现意外错误，请联系QQ：2513505027，我们将对您进行补发" preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *b = [UIAlertAction actionWithTitle:@"我已记下" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    
                                }];
                                
                                UIAlertAction *c = [UIAlertAction actionWithTitle:@"复制QQ" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    [UIPasteboard generalPasteboard].string = @"2513505027";
                                }];
                                
                                [a addAction:b];
                                [a addAction:c];
                                [self presentViewController:a animated:true completion:^{
                                    [self.navigationController popToRootViewControllerAnimated:true];
                                }];
                            }
                        }];
                        
                    }else{
                        
                        //扣除功德失败
                        [SVProgressHUD dismiss];
                        [SVProgressHUD showWithStatus:error.description];
                        [SVProgressHUD dismissWithDelay:1.5f];
                    }
                }];
            }else{
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:@"功德不足，请继续加油"];
                [SVProgressHUD dismissWithDelay:1.5f];
            }
        }
    }];
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
