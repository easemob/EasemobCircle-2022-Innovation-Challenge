//
//  DeliverTableViewController.m
//  XuefoQiFu
//
//  Created by Mac on 2022/1/26.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import "DeliverTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "DeliverTableViewCell.h"
#import <SVProgressHUD.h>
#import "UUID.h"
@interface DeliverTableViewController ()
@property (nonatomic ,copy)NSMutableArray *dataArr;
@end

@implementation DeliverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"已兑换记录";
    [SVProgressHUD show];
    [self.tableView registerNib:[UINib nibWithNibName:@"DeliverTableViewCell" bundle:nil] forCellReuseIdentifier:@"dcells"];
    _dataArr = [NSMutableArray array];
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *idfv = [UUID getUUID];
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"Deliver"];
    
    [bquery whereKey:@"UNIC" equalTo:idfv];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        for(BmobObject *b in array){
            [_dataArr addObject:b];
        }
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    }];
    
    UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        [self.tableView setTableFooterView:view];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    
    if (_dataArr.count == 0) {
            // Display a message when the table is empty
            // 没有数据的时候，UILabel的显示样式
            UILabel *messageLabel = [UILabel new];
     
            messageLabel.text = @"暂无兑换记录";
            messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            messageLabel.textColor = [UIColor blackColor];
            messageLabel.textAlignment = NSTextAlignmentCenter;
            [messageLabel sizeToFit];
     
            tableView.backgroundView = messageLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        } else {
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
    
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    DeliverTableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"dcells"];
    BmobObject *b = _dataArr[indexPath.row];
    c.selectionStyle = UITableViewCellSelectionStyleNone;
    c.productTitleLb.text = [b objectForKey:@"productName"];
    c.receveMsgLb.text = [NSString stringWithFormat:@"收货人：%@，收货号码：%@",[b objectForKey:@"name"],[b objectForKey:@"phone"]];
    c.addressLb.text = [NSString stringWithFormat:@"收货地址：%@",[b objectForKey:@"address"]];
    switch ([[b objectForKey:@"status"] integerValue]) {
        case 0:
            c.statuLb.text = @"待发货";
            break;
        case 1:
            c.statuLb.text = @"已发货";
            break;
        case 2:
            c.statuLb.text = @"已送达";
            break;
        case 3:
            c.statuLb.text = @"已送达";
            break;
        case 4:
            c.statuLb.text = @"已完成";
            break;
            
        default:
            break;
    }
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 120;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
