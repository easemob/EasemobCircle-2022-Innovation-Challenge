//
//  EMChatroomMutesViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatroomMutesViewController.h"

#import "EMAvatarNameCell.h"
#import "UIViewController+Util.h"
#import "UIViewController+HUD.h"
#import <Masonry.h>
#import "EMDefines.h"
#import "EMColorDefine.h"
#import "EaseCallDefine.h"
#import "EMAlertController.h"
@interface EMChatroomMutesViewController ()

@property (nonatomic, strong) EMChatroom *chatroom;
@property (nonatomic) BOOL isUpdated;

@end

@implementation EMChatroomMutesViewController

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom
{
    self = [super init];
    if (self) {
        self.chatroom = aChatroom;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isUpdated = NO;
    
    [self _setupSubviews];
    [self _fetchChatroomMutesWithIsHeader:YES isShowHUD:YES];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItemWithTarget:self action:@selector(backAction)];
    self.title = NSLocalizedString(@"chatroomMutes", nil);
    self.showRefreshHeader = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMAvatarNameCell *cell = (EMAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"EMAvatarNameCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMAvatarNameCell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.nameLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    cell.indexPath = indexPath;
    
    return cell;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
        [self showHudInView:self.view hint:NSLocalizedString(@"removeMuteList", nil)];
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].roomManager unmuteMembers:@[userName] fromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakself hideHud];
            if (aError) {
                [EMAlertController showErrorAlert:NSLocalizedString(@"unmuteGroupMemberFail", nil)];
            } else {
                weakself.isUpdated = YES;
                [EMAlertController showSuccessAlert:NSLocalizedString(@"unmuteGroupMemberSuccess", nil)];
                [weakself.dataArray removeObject:userName];
                [weakself.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Data

- (void)_fetchChatroomMutesWithIsHeader:(BOOL)aIsHeader
                              isShowHUD:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchMuteList...", nil)];
    }
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager getChatroomMuteListFromServerWithId:self.chatroom.chatroomId pageNumber:self.page pageSize:50 completion:^(NSArray *aList, EMError *aError) {
        if (aIsShowHUD) {
            [weakself hideHud];
        }
        
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            if (aIsHeader) {
                [weakself.dataArray removeAllObjects];
            }
            [weakself.dataArray addObjectsFromArray:aList];
            
            if ([aList count] == 0) {
                weakself.showRefreshFooter = NO;
            } else {
                weakself.showRefreshFooter = YES;
            }
            
            [weakself.tableView reloadData];
        }
        
        [weakself tableViewDidFinishTriggerHeader:aIsHeader reload:NO];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchChatroomMutesWithIsHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self _fetchChatroomMutesWithIsHeader:NO isShowHUD:NO];
}

#pragma mark - Action

- (void)backAction
{
    if (self.isUpdated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATROOM_INFO_UPDATED object:self.chatroom];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
