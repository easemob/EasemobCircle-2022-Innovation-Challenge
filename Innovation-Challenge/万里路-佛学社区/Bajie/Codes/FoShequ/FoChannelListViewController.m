//
//  FoChannelListViewController.m
//  XuefoQiFu
//
//  Created by Mac on 2022/12/16.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import "FoChannelListViewController.h"
#import "Cells/FoSheQuListTableViewCell.h"
#import "EMChatViewController.h"
//#import "EMGroupOptions.h"
@import HyphenateChat;
@interface FoChannelListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    EMCursorResult<EMCircleChannel *> * results;
    
    int tempIndex;
}

@end

@implementation FoChannelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    [self.mainTableView registerNib:[UINib nibWithNibName:@"FoSheQuListTableViewCell" bundle:nil] forCellReuseIdentifier:@"channelCells"];
    
    [[[EMClient sharedClient] circleManager] fetchPublicChannelsInServer:self.serverId limit:20 cursor:nil completion:^(EMCursorResult<EMCircleChannel *> * _Nullable result, EMError * _Nullable error) {
        self->results = result;
        for (int i = 0; i<result.list.count; i++) {
            EMCircleChannel *c = result.list[i];
            [[[EMClient sharedClient] circleManager] joinChannel:self.serverId channelId:c.channelId completion:^(EMCircleChannel * _Nullable channel, EMError * _Nullable error) {
                
            }];
        }
        
        [self.mainTableView reloadData];
        
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    
    return results.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    FoSheQuListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelCells"];
    EMCircleChannel *c = results.list[indexPath.row];
    cell.servesName.text = c.name;
    cell.servesDesc.text = c.desc;
    cell.serverId = self.serverId;
    cell.channelId = c.channelId;
    [cell updateMemb];
    [cell.deleteChannelBtn addTarget:self action:@selector(clickToDelete:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)clickToDelete:(UIButton *)sender{
    FoSheQuListTableViewCell *c = [[sender superview] superview];
    
    [[[EMClient sharedClient] circleManager] destroyChannel:self.serverId channelId:c.channelId completion:^(EMError * _Nullable error) {
        [SVProgressHUD showSuccessWithStatus:@"成功删除"];
        [SVProgressHUD dismissWithDelay:1.0];
        [[[EMClient sharedClient] circleManager] fetchPublicChannelsInServer:self.serverId limit:20 cursor:nil completion:^(EMCursorResult<EMCircleChannel *> * _Nullable result, EMError * _Nullable error) {
            self->results = result;
            [self.mainTableView reloadData];
            
        }];
    }];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 111;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FoSheQuListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSMutableArray<NSString*>*arr = [NSMutableArray new];
//    [arr addObject:@"admin"];
    for (int i = 0; i<cell.results.list.count; i++) {
        [arr addObject:cell.results.list[i].userId];
    }
    // 同步方法，异步方法见 [EMChatroomManager createChatroomWithSubject:description:invitees:message:maxMembersCount:completion]
    
    EMGroupOptions *options = [[EMGroupOptions alloc] init];
    // 设置群组最大成员数量。
    options.maxUsersCount = 500;
    // 设置 `IsInviteNeedConfirm` 为 `YES`，则邀请用户入群需要用户确认。
    options.IsInviteNeedConfirm = NO;
    // 设置群组类型。此处示例为成员可以邀请用户入群的私有群组。
    options.style = EMGroupStylePublicOpenJoin;
//    NSArray *members = @{@"member1",@"member2"};
    // 调用 `createGroupWithSubject` 创建群组。同步方法，异步方法见 [EMGroupManager createGroupWithSubject:description:invitees:message:setting:completion:]
    
//    NSArray *a = @[@"通用",@"佛教音乐",@"六字真言",@"金刚般若波罗蜜经",@"大悲咒",@"通用",@"每日礼佛签到",@"每日朗诵签到",@"通用",@"佛学交流2",@"佛学交流1",@"通用",@"禅论区2",@"禅论区1"];
//    for (int i = 0; i<14; i++) {
//        EMError *err = nil;
//        EMGroup *gg = [[EMClient sharedClient].groupManager createGroupWithSubject:a[a.count - tempIndex - 1]
//                                 description:@"无"
//                                 invitees:arr
//                                 message:@"无"
//                                 setting:options
//                                 error:&err];
//
//    tempIndex+=1;
//    }
    
    
//    EMError *error = nil;
//    EMChatroom *retChatroom = [[EMClient sharedClient].roomManager createChatroomWithSubject:@"aSubject" description:@"aDescription" invitees:arr message:@"aMessage" maxMembersCount:10 error:&error];
    
    // 从服务器获取公开群组列表
    NSMutableArray <EMGroup *>*memberList = [[NSMutableArray alloc]init];
//    NSInteger pageSize = 50;
    NSString *cursor = nil;
    EMCursorResult *result = [[EMCursorResult alloc]init];
//    do {
//      // 同步方法，异步方法见 [EMGroupManager getPublicGroupsFromServerWithCursor:pageSize:completion:]
        result = [[EMClient sharedClient].groupManager
                                          getPublicGroupsFromServerWithCursor:cursor
                                          pageSize:50
                                          error:nil];
        [memberList addObjectsFromArray:result.list];
//        cursor = result.cursor;
//    } while (result && result.list < pageSize);
//    // 同步方法，异步方法见 [EMGroupManager joinPublicGroup:completion:]
//    [[EMClient sharedClient].groupManager joinPublicGroup:gg.groupId error:nil];
    
    
    for (int i = 0; i<result.list.count; i++) {
//        [[EMClient sharedClient].groupManager destroyGroup:memberList[i].groupId finishCompletion:^(EMError * _Nullable aError) {
//
//        }];
        [[EMClient sharedClient].groupManager joinPublicGroup:memberList[i].groupId completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
//            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"错误:%@",aError.errorDescription]];
                }];
        
    }
    
    
    if([self.title isEqualToString:@"禅音"]){
        EMChatViewController *c = [[EMChatViewController alloc] initWithConversationId:memberList[indexPath.row].groupId conversationType:EMConversationTypeGroupChat andMode:2];
        [self.navigationController pushViewController:c animated:true];
    }else if ([self.title isEqualToString:@"每日打卡"]){
        EMChatViewController *c = [[EMChatViewController alloc] initWithConversationId:memberList[indexPath.row+5].groupId conversationType:EMConversationTypeGroupChat andMode:1];
        [self.navigationController pushViewController:c animated:true];
    }else if ([self.title isEqualToString:@"自由发言"]){
        EMChatViewController *c = [[EMChatViewController alloc] initWithConversationId:memberList[indexPath.row+8].groupId conversationType:EMConversationTypeGroupChat andMode:0];
        [self.navigationController pushViewController:c animated:true];
    }else if ([self.title isEqualToString:@"论禅社区"]){
        EMChatViewController *c = [[EMChatViewController alloc] initWithConversationId:memberList[indexPath.row+11].groupId conversationType:EMConversationTypeGroupChat andMode:3];
        [self.navigationController pushViewController:c animated:true];
    }
    
    
    
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
