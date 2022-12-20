//
//  DHDetailViewController.h
//  XuefoQiFu
//
//  Created by Mac on 2022/1/26.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>
NS_ASSUME_NONNULL_BEGIN

@interface DHDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIImageView *mainImg;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLb;
@property (weak, nonatomic) IBOutlet UITextView *mainContentTV;
@property (weak, nonatomic) IBOutlet UITextField *addressTf;
@property (weak, nonatomic) IBOutlet UITextField *nameTf;
@property (weak, nonatomic) IBOutlet UITextField *phoneTf;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property(nonatomic,strong)BmobObject *mainB;

@end

NS_ASSUME_NONNULL_END
