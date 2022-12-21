//
//  FoSheQuListViewController.m
//  XuefoQiFu
//
//  Created by Mac on 2022/12/16.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import "FoSheQuListViewController.h"
#import "Cells/FoSheQuListTableViewCell.h"
#import "FoChannelListViewController.h"
@import HyphenateChat;
@interface FoSheQuListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    EMCursorResult<EMCircleServer *> *results;
}

@end

@implementation FoSheQuListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.title = @"佛社区大全";
    [self.mainTableView registerNib:[UINib nibWithNibName:@"FoSheQuListTableViewCell" bundle:nil] forCellReuseIdentifier:@"sqCells"];
    [[[EMClient sharedClient] circleManager] fetchJoinedServers:20 cursor:nil completion:^(EMCursorResult<EMCircleServer *> * _Nullable result, EMError * _Nullable error) {
        self->results = result;
        [self.mainTableView reloadData];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return results.list.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FoSheQuListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sqCells"];
    EMCircleServer *s = results.list[indexPath.row];
    cell.servesName.text = s.name;
    cell.servesDesc.text = s.desc;
    cell.addMemb.hidden = true;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 141;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EMCircleServer *s = results.list[indexPath.row];
//    if(indexPath.row == 1){
//        EMCircleChannelAttribute *a = [[EMCircleChannelAttribute alloc]init];
//        a.name = @"每日朗诵签到";
//        a.desc = @"顺境逆境，不往往生西方";
//        [[[EMClient sharedClient] circleManager] createChannel:s.serverId attribute:a type:EMCircleChannelPublic completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
//            [SVProgressHUD showSuccessWithStatus:@"成功创建serv1 channel"];
//        }];
//
//
//    }else if(indexPath.row == 0){
//        EMCircleChannelAttribute *a = [[EMCircleChannelAttribute alloc]init];
//        a.name = @"大悲咒朗诵";
//        a.desc = @"念佛改变生活的现状,从此心不再迷茫";
//        [[[EMClient sharedClient] circleManager] createChannel:s.serverId attribute:a type:EMCircleChannelPublic completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
////            [SVProgressHUD showSuccessWithStatus:@"成功创建serv2 channel"];
//        }];
//
//        EMCircleChannelAttribute *b = [[EMCircleChannelAttribute alloc]init];
//        b.name = @"六字真言念诵";
//        b.desc = @"唵嘛呢叭咪吽";
//        [[[EMClient sharedClient] circleManager] createChannel:s.serverId attribute:b type:EMCircleChannelPublic completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
////            [SVProgressHUD showSuccessWithStatus:@"成功创建serv2 channel"];
//        }];
//
//
//        EMCircleChannelAttribute *c = [[EMCircleChannelAttribute alloc]init];
//        c.name = @"金刚般若波罗蜜经";
//        c.desc = @"佛教经典念诵";
//        [[[EMClient sharedClient] circleManager] createChannel:s.serverId attribute:c type:EMCircleChannelPublic completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
////            [SVProgressHUD showSuccessWithStatus:@"成功创建serv2 channel"];
//        }];
//
//
//    }else if(indexPath.row == 2){
//        EMCircleChannelAttribute *a = [[EMCircleChannelAttribute alloc]init];
//        a.name = @"佛学交流1";
//        a.desc = @"各抒己见，自由交流";
//        [[[EMClient sharedClient] circleManager] createChannel:s.serverId attribute:a type:EMCircleChannelPublic completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
////            [SVProgressHUD showSuccessWithStatus:@"成功创建serv2 channel"];
//        }];
//
//        EMCircleChannelAttribute *b = [[EMCircleChannelAttribute alloc]init];
//        b.name = @"佛学交流2";
//        b.desc = @"各抒己见，自由交流";
//        [[[EMClient sharedClient] circleManager] createChannel:s.serverId attribute:b type:EMCircleChannelPublic completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
////            [SVProgressHUD showSuccessWithStatus:@"成功创建serv2 channel"];
//        }];
//
//    }else if(indexPath.row == 3){
//        EMCircleChannelAttribute *a = [[EMCircleChannelAttribute alloc]init];
//        a.name = @"禅论区1";
//        a.desc = @"各抒己见，自由交流(纯文字)";
//        [[[EMClient sharedClient] circleManager] createChannel:s.serverId attribute:a type:EMCircleChannelPublic completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
////            [SVProgressHUD showSuccessWithStatus:@"成功创建serv2 channel"];
//        }];
//
//        EMCircleChannelAttribute *b = [[EMCircleChannelAttribute alloc]init];
//        b.name = @"禅论区2";
//        b.desc = @"各抒己见，自由交流(纯文字)";
//        [[[EMClient sharedClient] circleManager] createChannel:s.serverId attribute:b type:EMCircleChannelPublic completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
////            [SVProgressHUD showSuccessWithStatus:@"成功创建serv2 channel"];
//        }];
//
//    }
    
    
    FoChannelListViewController *c = [[FoChannelListViewController alloc] initWithNibName:@"FoChannelListViewController" bundle:nil];
    c.serverId = s.serverId;
    c.title = s.name;
    [self.navigationController pushViewController:c animated:true];
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
