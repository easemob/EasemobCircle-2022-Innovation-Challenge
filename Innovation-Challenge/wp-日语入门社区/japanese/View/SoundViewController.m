//
//  SoundViewController.m
//  japanese
//
//  Created by LYQ on 2021/2.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "SoundViewController.h"
#import "JPSoundPageViewController.h"
#import "YSLContainerViewController.h"
#import "JPUtils.h"
@import GoogleMobileAds;
@interface SoundViewController()<YSLContainerViewControllerDelegate>
@property(nonatomic, strong) GADBannerView *bannerView;
@end
@implementation SoundViewController

- (void)viewDidLoad {
    self.title = @"五十音图";
    JPSoundPageViewController *qingYinViewController = [[JPSoundPageViewController alloc] init];
    JPSoundPageViewController *qingAoYinViewController = [[JPSoundPageViewController alloc] init];
    JPSoundPageViewController *zhuoYinViewController = [[JPSoundPageViewController alloc] init];
    JPSoundPageViewController *zhuoAoYinViewController = [[JPSoundPageViewController alloc] init];

    qingYinViewController.title = @"清音";
    qingYinViewController.soundArray = JPUtils.getQYSoundArray;
    qingYinViewController.soundType = 1;

    qingAoYinViewController.title = @"清拗音";
    qingAoYinViewController.soundArray = JPUtils.getQAYSoundArray;
    qingAoYinViewController.soundType = 2;

    zhuoYinViewController.title = @"浊音";
    zhuoYinViewController.soundArray = JPUtils.getZYSoundArray;
    zhuoYinViewController.soundType = 3;

    zhuoAoYinViewController.title = @"浊拗音";
    zhuoAoYinViewController.soundArray = JPUtils.getZAYSoundArray;
    zhuoAoYinViewController.soundType = 4;

    YSLContainerViewController *yslContainerVC = [[YSLContainerViewController alloc] initWithControllers:@[qingYinViewController,qingAoYinViewController,zhuoYinViewController,zhuoAoYinViewController] topBarHeight:StartY parentViewController:self];
    yslContainerVC.delegate = self;
    yslContainerVC.menuItemFont = [UIFont fontWithName:@"Futura-Medium" size:16];
    [self.view addSubview:yslContainerVC.view];

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

- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller {
    [controller viewWillAppear:YES];
}

@end
