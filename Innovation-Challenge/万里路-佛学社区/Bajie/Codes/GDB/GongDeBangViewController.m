//
//  GongDeBangViewController.m
//  XuefoQiFu
//
//  Created by Mac on 2022/1/24.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import "GongDeBangViewController.h"
#import "GongDeTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import <SVProgressHUD.h>
#import "UUID.h"
@interface GongDeBangViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)NSMutableArray *dataArr;
@property (nonatomic,copy)BmobObject *selfObj;
@end

@implementation GongDeBangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"佛社区";
    _dataArr = [NSMutableArray array];
    // Do any additional setup after loading the view from its nib.
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [_mainTableView registerNib:[UINib nibWithNibName:@"GongDeTableViewCell" bundle:nil] forCellReuseIdentifier:@"gdcell"];
    
    
   
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"兑换" style:UIBarButtonItemStylePlain target:self action:@selector(goToDH)];
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (void)viewWillAppear:(BOOL)animated{
    [SVProgressHUD show];
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"AppInfo"];
    //查找GameScore表的数据
    [bquery orderByDescending:@"GongDeCounts"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        [SVProgressHUD dismiss];
//        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *idfv = [UUID getUUID];
        BmobQuery   *bquery2 = [BmobQuery queryWithClassName:@"AppInfo"];
        [bquery2 whereKey:@"UNIC" equalTo:idfv];
        
        [bquery2 findObjectsInBackgroundWithBlock:^(NSArray *array2, NSError *error) {
        for (BmobObject *obj in array2) {
            _selfObj = obj;
        }
            self.myPaiMingLb.text = [NSString stringWithFormat:@"我:%@ -- 功德值:%@",[_selfObj objectForKey:@"NickName"],[_selfObj objectForKey:@"GongDeCounts"]];
            NSInteger num = [[_selfObj objectForKey:@"GongDeCounts"] integerValue];
            NSInteger xx = 1;
            for (BmobObject *obj in array) {
                NSInteger ti = [[obj objectForKey:@"GongDeCounts"] integerValue];
                if(ti>num){
                    xx++;
                }
            }
            if(xx>10){
                self.myNumberLb.text = [NSString stringWithFormat:@"排名:(未入榜)"];
            }else{
                self.myNumberLb.text = [NSString stringWithFormat:@"排名:%ld",xx];
                self.myNumberLb.textColor = UIColor.orangeColor;
            }
        }];
        if(_dataArr.count!=0){
            _dataArr = [NSMutableArray array];
        }
    for (BmobObject *obj in array) {
        [self->_dataArr addObject:obj];
    }
        [self->_mainTableView reloadData];
    }];
}


-(void)goToDH{
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    
    if(_dataArr.count<10){
        return _dataArr.count;
    }
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    GongDeTableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"gdcell"];
    if(indexPath.row == 0){
        c.brigdeImg.hidden = false;
    }else{
        c.brigdeImg.hidden = true;
        c.userNameLb.textColor = UIColor.blackColor;
        c.userCountLb.textColor = UIColor.blackColor;
    }
    c.selectionStyle = UITableViewCellSelectionStyleNone;
    c.paiMingLb.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    BmobObject *b = _dataArr[indexPath.row];
    
    c.userNameLb.text = [NSString stringWithFormat:@"功德人：%@",[b objectForKey:@"NickName"]];
    
    c.userCountLb.text = [NSString stringWithFormat:@"功德值：%@",[b objectForKey:@"GongDeCounts"]];
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        return 80;
    }else{
        return 60;
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
