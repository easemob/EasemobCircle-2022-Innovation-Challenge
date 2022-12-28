//
//  AboutsViewController.m
//  japanese
//
//  Created by Mac on 2021/4/20.
//  Copyright © 2021 Hebe. All rights reserved.
//

#import "AboutsViewController.h"
@import GoogleMobileAds;
@interface AboutsViewController ()
@property(nonatomic, strong) GADBannerView *bannerView;
@end

@implementation AboutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"关于我们";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
