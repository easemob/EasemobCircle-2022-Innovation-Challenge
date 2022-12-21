//
//  HuanyuanViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/10/2.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "HuanyuanViewController.h"
#import "YuanwangViewController.h"
#import <Masonry.h>
#import "AppDelegate.h"
#import <SVProgressHUD.h>
#import <FlatUIKit.h>
#import "YuanDetailViewController.h"
#import "YWTableViewCell.h"
#import <KGModal.h>
#import "tooles.h"
#import <MJRefresh.h>

@interface HuanyuanViewController ()<UITableViewDelegate,UITableViewDataSource,ydDelegate>

@property(nonatomic,strong) NSArray *wishArray;
@property(nonatomic,strong) UITableView *listView;
@property(nonatomic,strong) FUIButton *xyButton;
@property(nonatomic,strong) MJRefreshNormalHeader *listheader;
@property(nonatomic,strong) MJRefreshAutoNormalFooter *listfooter;
@property(nonatomic,assign) NSInteger nowPage;
@property(nonatomic,assign) NSInteger pageEleCount;

@property(nonatomic,strong) YuanDetailViewController *ydVC;

@end

@implementation HuanyuanViewController

@synthesize nowPage;
@synthesize pageEleCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = MMColorOrange;
        
        self.nowPage = 0;
        self.pageEleCount = 30;
        
        self.wishArray = [NSArray array];
        
        self.listView = [UITableView new];
        self.listView.backgroundColor = [UIColor clearColor];
        self.listView.dataSource = self;
        self.listView.delegate = self;
        self.listView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.listView.separatorColor = [UIColor blackColor];
        self.listView.autoresizingMask = UIViewAutoresizingFlexibleHeight |    UIViewAutoresizingFlexibleWidth;

//        self.listheader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            // 进入刷新状态后会自动调用这个block
//            [self queryTheList:NO];
//        }];
        self.listheader.lastUpdatedTimeLabel.hidden = YES;
        [self.listheader setTitle:@"下拉进行刷新" forState:MJRefreshStateIdle];
        [self.listheader setTitle:@"松开刷新" forState:MJRefreshStatePulling];
        [self.listheader setTitle:@"刷新中..." forState:MJRefreshStateRefreshing];
        self.listheader.stateLabel.textColor = [UIColor whiteColor];
        self.listheader.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
        self.listView.mj_header = self.listheader;
        
//        self.listfooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//            [self queryTheList:NO];
//        }];
        [self.listfooter setTitle:@"继续上拉加载更多" forState:MJRefreshStateIdle];
        [self.listfooter setTitle:@"加载中……" forState:MJRefreshStateRefreshing];
        [self.listfooter setTitle:@"到尽头啦" forState:MJRefreshStateNoMoreData];
        self.listfooter.stateLabel.textColor = [UIColor whiteColor];
        self.listView.mj_footer = self.listfooter;
        
        [self.view addSubview:self.listView];
        
        self.xyButton = [FUIButton new];
        self.xyButton.buttonColor = MMColorRed;
        self.xyButton.shadowColor = MMColorShadowRed;
        self.xyButton.shadowHeight = 3.0f;
        self.xyButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        [self.xyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.xyButton setTitle:@"我要许愿" forState:UIControlStateNormal];
        [self.xyButton addTarget:self action:@selector(xyPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.xyButton];
        
        self.ydVC = [YuanDetailViewController new];
        self.ydVC.delegate = self;
        
        UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            [_listView setTableFooterView:view];
    }
    return self;
}

-(void)showQiFuList{
    NSUserDefaults *s = [NSUserDefaults standardUserDefaults];
    
}

//-(void)queryTheList:(Boolean)isHead{
//    if (isHead) {
//        self.nowPage = 0;
//        [self.listfooter setState:MJRefreshStateIdle];
//    }else{
//        self.nowPage++;
//    }
//    AVQuery *query = [AVQuery queryWithClassName:@"WishTree"];
//    query.limit = self.pageEleCount;
//    query.skip = self.nowPage * self.pageEleCount;
//    [query orderByDescending:@"wishid"];
//    [SVProgressHUD showWithStatus:@"加载中..."];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            [SVProgressHUD dismiss];
//            if (isHead) {
//                self.wishArray = objects;
//                [self.listView reloadData];
//                [self.listView scrollsToTop];
//                [self.listheader endRefreshing];
//            }else {
//                self.wishArray = [self.wishArray arrayByAddingObjectsFromArray:objects];
//                [self.listView reloadData];
//                [self.listView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//                [self.listfooter endRefreshing];
//            }
//            if ([objects count] < self.pageEleCount) {
//                [self.listfooter endRefreshingWithNoMoreData];
//            }
//        } else {
//            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"获取失败:%@", error]];
//            if (isHead) {
//                self.nowPage = 0;
//                self.wishArray = [NSArray array];
//                [self.listView reloadData];
//                [self.listView scrollsToTop];
//                [self.listheader endRefreshing];
//            }else {
//                // nothing changes with wisharray
//                self.nowPage--;
//                // self.wishArray = [NSArray array];
//                [self.listView reloadData];
//                [self.listView scrollsToTop];
//                [self.listfooter endRefreshingWithNoMoreData];
//            }
//        }
//    }];
//}

-(void)segChanged:(id)sender{
    [self.listheader beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    WS(ws);
    
    [self.xyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view);
        make.right.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(40);
    }];
    
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view.mas_left);
        make.right.mas_equalTo(ws.view.mas_right);
        make.top.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(self.xyButton.mas_top);
    }];
    [self segChanged:nil];
    [self.listView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *a = [[NSUserDefaults standardUserDefaults] objectForKey:@"qifuArray"];
    if (a.count == 0) {
            // Display a message when the table is empty
            // 没有数据的时候，UILabel的显示样式
            UILabel *messageLabel = [UILabel new];
     
            messageLabel.text = @"无许愿记录，许愿需心诚。";
            messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            messageLabel.textColor = [UIColor whiteColor];
            messageLabel.textAlignment = NSTextAlignmentCenter;
            [messageLabel sizeToFit];
     
            tableView.backgroundView = messageLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        } else {
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
    return a.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   
    YWTableViewCell *cell = nil;
    static NSString *cellIdentifier = @"HuanyuanCellID";
    // Similar to UITableViewCell, but
    cell = (YWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[YWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    AVObject *item = [self.wishArray objectAtIndex:indexPath.row];
//    NSDate *date = (NSDate*)item.createdAt;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //设置格式：zzz表示时区
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    //NSDate转NSString
//    NSString *currentDateString = [dateFormatter stringFromDate:date];
//    // Just want to test, so I hardcode the data
//    cell.foImgView.image = [UIImage imageNamed:[tooles getPicNameByFoName:item[@"foname"]]];
//    cell.numberLabel.text = [NSString stringWithFormat:@"第%d个祈福",[item[@"wishid"] intValue]];
//    cell.nameLabel.text = item[@"username"];
//    cell.titleLabel.text = item[@"title"];
//    cell.mainLabel.text = item[@"content"];
//    cell.dateLabel.text = currentDateString;
//    cell.moneyLabel.text = [item[@"gold"] intValue] == 0?@"":[NSString stringWithFormat:@"㉤%d",[item[@"gold"] intValue]];
    NSUserDefaults *ss = [NSUserDefaults standardUserDefaults];
    NSMutableArray *a = [ss objectForKey:@"qifuArray"];
    NSMutableDictionary *s = a[indexPath.row];
    cell.foImgView.image = [UIImage imageNamed:[tooles getPicNameByFoName:[s objectForKey:@"foname"]]];
    cell.numberLabel.text =[NSString stringWithFormat:@"第%ld个祈愿",indexPath.row+1];
    cell.nameLabel.text = [s objectForKey:@"username"];
    cell.titleLabel.text = [s objectForKey:@"title"];
    cell.mainLabel.text = [s objectForKey:@"content"];
    NSDate *date = [s objectForKey:@"wishdate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateString = [dateFormatter stringFromDate:date];
    cell.dateLabel.text = currentDateString;
    cell.moneyLabel.text = [[s objectForKey:@"gold"] intValue] == 0?@"":[NSString stringWithFormat:@"㉤%d",[[s objectForKey:@"gold"] intValue]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    AVObject *item = [self.wishArray objectAtIndex:indexPath.row];
    NSUserDefaults *ss = [NSUserDefaults standardUserDefaults];
   NSMutableArray *a = [ss objectForKey:@"qifuArray"];
    NSMutableDictionary *s = a[indexPath.row];
    self.ydVC.numArray = indexPath.row;
    self.ydVC.listView = self.listView;
    self.ydVC.myWish = s;
    [APPALL.myKGModal showWithContentViewController:self.ydVC];
}

-(void)xyPressed:(id)sender{
//    if(!APPALL.myUserItem.username.length){
//        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请先完善您的个人信息" message:@"在向佛祖祈福前，请您前往个人中心-编辑资料中完善您的个人资料。" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *ac = [UIAlertAction actionWithTitle:@"" style:<#(UIAlertActionStyle)#> handler:<#^(UIAlertAction * _Nonnull action)handler#>]
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的，立刻前往" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//            [self.tabBarController setSelectedIndex:3];
////            self.title = @"个人主页";
//        }];
//        [vc addAction:cancelAction];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self presentViewController:vc animated:YES completion:nil];
//        });
//        return;
//    }
    YuanwangViewController *vc = [YuanwangViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)ydClickIndex:(NSInteger)buttonIndex {
    NSLog(@"ydCLickllll:%ld",buttonIndex);
    [self segChanged:nil];
//    if (buttonIndex == 1) {// 编辑
//        YwEditVController *vc = [YwEditVController new];
//        [vc setWishItem:self.ydVC.myWish];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else if (buttonIndex == 2) {//祝福ta
//    }
}

@end

