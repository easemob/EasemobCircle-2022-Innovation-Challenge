//
//  FojingMuluViewController.m
//  Xuefoqifu
//
//  Created by Mac on 2019/12/24.
//  Copyright © 2019 Sunmingming. All rights reserved.
//

#import "FojingMuluViewController.h"
#import "EachBuViewController.h"
#import "CustomBookTableViewCell.h"
@interface FojingMuluViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation FojingMuluViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
//    _mainTableView.sele
    self.title = @"藏经阁目录";
    [_mainTableView registerNib:[UINib nibWithNibName:@"CustomBookTableViewCell" bundle:nil] forCellReuseIdentifier:@"Book"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EachBuViewController *e = [EachBuViewController new];
    
    switch (indexPath.row) {
        case 0:{
            e.bookCount = 0;
            e.title = @"阿含部";
        }
            break;
        case 1:{
            e.bookCount = 1;
            e.title = @"般若部";
            }
                break;
            case 2:{
                e.bookCount = 2;
                e.title = @"法华部";
            }
                break;
            case 3:{
                e.bookCount = 3;
                e.title = @"方等部";
            }
                break;
            case 4:{
                e.bookCount = 4;
                e.title = @"经集部";
            }
                break;
            case 5:{
                e.bookCount = 5;
                e.title = @"律部";
            }
                break;
            case 6:{
                e.bookCount = 6;
                e.title = @"密教部";
            }
                break;
            case 7:{
                e.bookCount = 7;
                e.title = @"涅槃部";
            }
                break;
            case 8:{
                e.bookCount = 8;
                e.title = @"其他部";
            }
                break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:e animated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [[UITableViewCell alloc]init];
    CustomBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Book"];
//    cell.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:170.0/255.0 blue:75.0/255.0 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:{
            cell.titleLb.text = @"阿含部";
        }
            break;
        case 1:{
                cell.titleLb.text = @"般若部";
            }
                break;
            case 2:{
                cell.titleLb.text = @"法华部";
            }
                break;
            case 3:{
                cell.titleLb.text = @"方等部";
            }
                break;
            
            case 4:{
                cell.titleLb.text = @"经集部";
            }
                break;
            case 5:{
                cell.titleLb.text = @"律部";
            }
                break;
            case 6:{
                cell.titleLb.text = @"密教部";
            }
                break;
            case 7:{
                cell.titleLb.text = @"涅槃部";
            }
                break;
            case 8:{
                cell.titleLb.text = @"其他部";
            }
                break;
            
        default:
            break;
    }
    cell.bookImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"阿 含-%ld",indexPath.row+1]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
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
