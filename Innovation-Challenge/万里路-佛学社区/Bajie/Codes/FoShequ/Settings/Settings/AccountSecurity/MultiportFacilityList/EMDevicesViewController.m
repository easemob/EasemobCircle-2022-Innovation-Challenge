//
//  EMDevicesViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 20/06/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import "EMDevicesViewController.h"

#import "EMDemoOptions.h"
#import "UIViewController+Util.h"
#import "UIViewController+HUD.h"
#import <Masonry.h>
#import "EMDefines.h"
#import "EMColorDefine.h"
#import "EaseCallDefine.h"
#import "EMAlertController.h"
#define KALERT_GET_ALL 1
#define KALERT_KICK_ALL 2
#define KALERT_KICK_ONE 3
@import HyphenateChat;
@interface EMDevicesViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic) BOOL isAuthed;

@end

@implementation EMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupSubviews];
    
    EMDemoOptions *options = [EMDemoOptions sharedOptions];
    self.username = options.loggedInUsername;
    self.password = options.loggedInPassword;
    if ([self.username length] > 0 && [self.password length] > 0) {
        self.isAuthed = YES;
    }
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    
    return _dataSource;
}


#pragma mark - Subviews

- (void)_setupSubviews
{
    [self addPopBackLeftItem];
    
    self.title = NSLocalizedString(@"deviceList", nil);
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    
    self.showRefreshHeader = YES;
    self.tableView.rowHeight = 66;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    
    UIImageView *imgView = [[UIImageView alloc]init];
    [cell.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(16);
        make.width.height.equalTo(@40);
    }];
    [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(15);
        make.top.equalTo(cell.contentView).offset(10);
        make.right.equalTo(cell.contentView).offset(15);
    }];
    [cell.detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(15);
        make.bottom.equalTo(cell.contentView).offset(-10);
        make.right.equalTo(cell.contentView).offset(15);
    }];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    
    EMDeviceConfig *options = [self.dataSource objectAtIndex:indexPath.row];
    
    NSRange range = [options.resource rangeOfString:@"_"];
    
    NSString *str = [options.resource substringToIndex:range.location];
    
    if ([str isEqualToString:@"ios"])
        imgView.image = [UIImage imageNamed:@"ios"];
    if ([str isEqualToString:@"android"])
        imgView.image = [UIImage imageNamed:@"android"];
    if ([str isEqualToString:@"webim"])
        imgView.image = [UIImage imageNamed:@"web"];
    if ([str isEqualToString:@"win"])
        imgView.image = [UIImage imageNamed:@"win"];
    if ([str isEqualToString:@"desktop"]) 
        imgView.image = [UIImage imageNamed:@"iMac"];
    
    cell.textLabel.text = options.deviceName;
    if ([options.deviceName length] == 0) {
        cell.textLabel.text = options.resource;
    }
    
    cell.detailTextLabel.text = options.deviceUUID;
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    return cell;
}

#pragma mark - Data

- (void)_fetchDevicesFromServer
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] getLoggedInDevicesFromServerWithUsername:self.username password:self.password completion:^(NSArray *aList, EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            weakself.isAuthed = YES;
            [weakself.dataSource removeAllObjects];
            [weakself.dataSource addObjectsFromArray:aList];
            [weakself.tableView reloadData];
        } else {
            if (aError.code == EMErrorUserAuthenticationFailed) {
                weakself.isAuthed = NO;
            }
            [weakself showHint:aError.errorDescription];
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    }];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:NSLocalizedString(@"delete", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself deleteCellAction:indexPath];
    }];
    
    NSArray *swipeActions = @[deleteAction];
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:swipeActions];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

- (void)tableViewDidTriggerHeaderRefresh
{
    if (!self.isAuthed) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"fetchRight", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"pwd", nil);
            textField.secureTextEntry = YES;
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *passwordField = alertController.textFields.firstObject;
            self.password = passwordField.text;
            
            if ([EMClient sharedClient].isLoggedIn && ![self.username isEqualToString:[EMClient sharedClient].currentUsername]) {
                [self.tableView.refreshControl endRefreshing];
                [self showHint:NSLocalizedString(@"inputPwd", nil)];
                return ;
            }
            
            [self _fetchDevicesFromServer];
        }];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self _fetchDevicesFromServer];
    }
}

- (void)deleteCellAction:(NSIndexPath *)aIndexPath
{
    EMDeviceConfig *device = [self.dataSource objectAtIndex:aIndexPath.row];
    
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Waiting...")];
    [[EMClient sharedClient] kickDeviceWithUsername:self.username password:self.password resource:device.resource completion:^(EMError *aError) {
        [weakself hideHud];
        if (!aError) {
            NSString *deviceName = [UIDevice currentDevice].name;
            if ([deviceName isEqualToString:device.deviceName]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_LOGIN_CHANGED object:@NO];
            } else {
                [weakself.dataSource removeObjectAtIndex:aIndexPath.row];
                [weakself.tableView deleteRowsAtIndexPaths:@[aIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            [EMAlertController showErrorAlert:aError.errorDescription];
        }
    }];
}

@end
