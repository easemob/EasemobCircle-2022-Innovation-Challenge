//
//  UserDataViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/9/27.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "UserDataViewController.h"
#import "UserInfoItem.h"
#import "MOFSPickerManager.h"
#import "AppDelegate.h"
#import <SVProgressHUD.h>
#import "UUID.h"
@interface UserDataViewController ()<UIAlertViewDelegate>

@property(nonatomic,strong) UserInfoItem *cacheUserItem;

@property(nonatomic,strong) NSString *nicknamestr;
@property(nonatomic,strong) NSString *sexstr;
@property(nonatomic,strong) NSString *citystr;
@property(nonatomic,strong) NSString *birthdaystr;

@property(nonatomic,assign) int alertTag;

@end

@implementation UserDataViewController

@synthesize cacheUserItem = _cacheUserItem;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.cacheUserItem = APPALL.myUserItem;
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人资料";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(savePressed:)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)savePressed:(id)sender{
//    if(!_cacheUserItem.username.length || _cacheUserItem.username.length >= 12){
//        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请正确填写您的姓名！" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        [vc addAction:cancelAction];
//			dispatch_async(dispatch_get_main_queue(), ^{
//				[self presentViewController:vc animated:YES completion:nil];
//			});
//        return;
//    }
//    if(!_cacheUserItem.sex.length){
//        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请选择您的性别！" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        [vc addAction:cancelAction];
//			dispatch_async(dispatch_get_main_queue(), ^{
//				[self presentViewController:vc animated:YES completion:nil];
//			});
//        return;
//    }
//    if(!_cacheUserItem.birthday.length){
//        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请选择您的生日！" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        [vc addAction:cancelAction];
//			dispatch_async(dispatch_get_main_queue(), ^{
//				[self presentViewController:vc animated:YES completion:nil];
//			});
//        return;
//    }
    
    
    
    
    APPALL.myUserItem = _cacheUserItem;
    [APPALL.myUserItem saveToDB];
    [self.myDelegate reloadListView];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"characteristicCell2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"姓名";
                    cell.detailTextLabel.text = [_mainObj objectForKey:@"NickName"];
                }
                    break;
                case 1:{
                    cell.textLabel.text = @"性别";
                    cell.detailTextLabel.text = self.cacheUserItem.sex;
                }
                    break;
                case 2:{
                    cell.textLabel.text = @"省市";
                    cell.detailTextLabel.text = self.cacheUserItem.city;
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"出生时辰";
                    cell.detailTextLabel.text = self.cacheUserItem.btime;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:{
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请输入您的名字" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    [vc addTextFieldWithConfigurationHandler:^(UITextField *textField){
                        textField.placeholder = @"";
                    }];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        UITextField *login = vc.textFields.firstObject;
                        NSLog(@"%@",login.text);
                        if(login.text.length){
                            NSString *s = [_mainObj objectForKey:@"NickName"];
                            if([s isEqualToString:login.text]){
                                
                            }else{
//                                NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                                NSString *idfv = [UUID getUUID];
                                BmobQuery   *bquery = [BmobQuery queryWithClassName:@"AppInfo"];
                                
                                [bquery whereKey:@"UNIC" equalTo:idfv];
                                [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                                    
                                for (BmobObject *obj in array) {
                                //打印playerName
                            //                allOBJ = obj;
                                    
                                            NSLog(@"数据加载成功");
                                    [obj setObject:login.text forKey:@"NickName"];
                                    [_mainObj setObject:login.text forKey:@"NickName"];
                                    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                                        if(isSuccessful){
                                            [self.tableView reloadData];
                                        }
                                    }];
                                }
                                    
                                }];
                            }
                        }
                    }];
                    [vc addAction:cancelAction];
                    [vc addAction:okAction];
					dispatch_async(dispatch_get_main_queue(), ^{
						[self presentViewController:vc animated:YES completion:nil];
					});
                }
                    break;
                case 1:{
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请选择您的性别" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *ok1Action = [UIAlertAction actionWithTitle:@"男"style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        self.cacheUserItem.sex = @"男";
                        [self.tableView reloadData];
                    }];
                    UIAlertAction *ok2Action = [UIAlertAction actionWithTitle:@"女"style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        self.cacheUserItem.sex = @"女";
                        [self.tableView reloadData];
                    }];
                    [vc addAction:ok1Action];
                    [vc addAction:ok2Action];
                    [vc addAction:cancelAction];
					dispatch_async(dispatch_get_main_queue(), ^{
						[self presentViewController:vc animated:YES completion:nil];
					});
                }
                    break;
                case 2:{
                    [[MOFSPickerManager shareManger] showMOFSAddressPickerWithTitle:nil cancelTitle:@"取消" commitTitle:@"完成" commitBlock:^(NSString *address, NSString *zipcode) {
                        self.cacheUserItem.city = address;
                        [self.tableView reloadData];
//                        lb.text = address;
                    } cancelBlock:^{
                        
                    }];
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
//                case 0:{
//                    [[MOFSPickerManager shareManger] showDatePickerWithTag:1 commitBlock:^(NSDate *date) {
//                        NSDateFormatter *df = [NSDateFormatter new];
//                        df.dateFormat = @"yyyy-MM-dd";
//                        self.cacheUserItem.birthday = [df stringFromDate:date];
//                        [self.tableView reloadData];
//                    } cancelBlock:^{
//                        
//                    }];
//                }
//                    break;
                case 0:{
                    [[MOFSPickerManager shareManger] showPickerViewWithDataArray:@[@"不清楚",@"子时(23时至01时)",@"丑时(01时至03时)",@"寅时(03时至05时)",@"卯时(05时至07时)",@"辰时(07时至09时)",@"巳时(09时至11时)",@"午时(11时至13时)",@"未时(13时至15时)",@"申时(15时至17时)",@"酉时(17时至19时)",@"戌时(19时至21时)",@"亥时(21时至23时)"] tag:1 title:nil cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *string) {
                        if(string.length > 5)
                            self.cacheUserItem.btime = [string substringToIndex:2];
                        else
                            self.cacheUserItem.btime = string;
                        [self.tableView reloadData];
                    } cancelBlock:^{

                    }];
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
