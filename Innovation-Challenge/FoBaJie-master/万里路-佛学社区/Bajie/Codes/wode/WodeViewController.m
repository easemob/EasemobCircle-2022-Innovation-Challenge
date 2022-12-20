//
//  WodeViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/8/31.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "WodeViewController.h"
#import "UserDataViewController.h"
#import "GuanyuViewController.h"
#import <FlatUIKit.h>
#import <Masonry.h>
#import <BmobSDK/Bmob.h>
#import "AppDelegate.h"
#import "DuiHuanTableViewController.h"
#import "UUID.h"
#import "DeliverTableViewController.h"
@import GoogleMobileAds;
@interface WodeViewController ()<UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate>

@property(nonatomic,strong) UIImageView *bgView;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic, strong) GADBannerView *bannerView;

@property (nonatomic,copy)BmobObject *mainB;
@end

@implementation WodeViewController

@synthesize bgView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
        
        self.bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_bg"]];
        self.bgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:bgView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,0,0) style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.view addSubview:self.tableView];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    WS(ws);
    
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *idfv = [UUID getUUID];
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"AppInfo"];
    [bquery whereKey:@"UNIC" equalTo:idfv];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
    for (BmobObject *obj in array) {
        _mainB = obj;
    }
        
        [self.tableView reloadData];
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kDeviceWidth-60);
        make.left.mas_equalTo(ws.view.mas_left);
        make.right.mas_equalTo(ws.view.mas_right);
        make.top.mas_equalTo(ws.view.mas_top);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view.mas_left);
        make.right.mas_equalTo(ws.view.mas_right);
        make.top.mas_equalTo(self.bgView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    [self.tableView reloadData];
    self.title = @"个人主页";
    [self.view bringSubviewToFront:self.bannerView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bannerView = [[GADBannerView alloc]
          initWithAdSize:kGADAdSizeBanner];
    [self addBannerViewToView:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-14);
    }];
  self.bannerView.adUnitID = @"ca-app-pub-9139925389247586/8468984247";
    self.bannerView.rootViewController = self;
  [self.bannerView loadRequest:[GADRequest request]];
  self.bannerView.delegate = self;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 4;
        case 1:
            return 2;
        default:
            return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"characteristicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:{
                    if(_mainB==nil){
                        cell.textLabel.text = @"尚未编辑资料";
											cell.detailTextLabel.text = @"";
                    } else {
                        
                        cell.textLabel.text = [_mainB objectForKey:@"NickName"];
											cell.detailTextLabel.text = @"修改资料";
                    }
                }
                    break;
                case 1:{
                    cell.textLabel.text = @"功德值";
                    if(_mainB){
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[_mainB objectForKey:@"GongDeCounts"]];
                    }else{
                        cell.detailTextLabel.text = @"0";
                    }
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 2:{
                    cell.textLabel.text = @"功德兑换";
//                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",@""];
//                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 3:{
                    cell.textLabel.text = @"查看已兑换";
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"关于";
                    cell.detailTextLabel.text = @"";
                }
                    break;
                case 1:{
                    cell.textLabel.text = @"声明";
                    cell.detailTextLabel.text = @"";
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}

-(void)reloadListView{
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:{
                    UserDataViewController *vc = [[UserDataViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    vc.myDelegate = self;
                    vc.mainObj = _mainB;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:{
                }
                    
                    break;
                case 2:{
                    DuiHuanTableViewController *vc = [[DuiHuanTableViewController alloc] initWithNibName:@"DuiHuanTableViewController" bundle:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3:{
                    DeliverTableViewController *vc = [[DeliverTableViewController alloc] initWithNibName:@"DeliverTableViewController" bundle:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:{
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];//app版本号 Version
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"关于应用" message:[NSString stringWithFormat:@"版本：%@\n学佛祈福是专业从事在线烧香、烧香拜佛、网上拜佛、礼佛、网上许愿的大型专业虚拟现实祭祀软件。您可以在这里免费获取烧香图解、上香图解、观香图、看香谱等信息。",version] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:cancelAction];
					dispatch_async(dispatch_get_main_queue(), ^{
						[self presentViewController:vc animated:YES completion:nil];
					});
                }
                    break;
                case 1:{
                    GuanyuViewController *vc = [GuanyuViewController new];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

@end
