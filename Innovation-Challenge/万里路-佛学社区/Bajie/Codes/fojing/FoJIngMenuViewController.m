//
//  FoJIngMenuViewController.m
//  Xuefoqifu
//
//  Created by Mac on 2019/12/24.
//  Copyright © 2019 Sunmingming. All rights reserved.
//

#import "FoJIngMenuViewController.h"
#import "FojingMuluViewController.h"
@import GoogleMobileAds;
@interface FoJIngMenuViewController ()<GADBannerViewDelegate>
@property(nonatomic, strong) GADBannerView *bannerView;
@end

@implementation FoJIngMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.bannerView = [[GADBannerView alloc]
          initWithAdSize:kGADAdSizeBanner];
    
      [self addBannerViewToView:self.bannerView];
    
    self.bannerView.adUnitID = @"ca-app-pub-9139925389247586/8468984247";
      self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    self.bannerView.delegate = self;
}
- (IBAction)inFojing:(id)sender {
    [self.navigationController pushViewController:[FojingMuluViewController new] animated:true];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
