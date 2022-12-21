//
//  DuiHuanTableViewController.m
//  XuefoQiFu
//
//  Created by Mac on 2022/1/25.
//  Copyright © 2022 Sunmingming. All rights reserved.
//

#import "DuiHuanTableViewController.h"
#import "DuHuanTableViewCell.h"
#import "DHDetailViewController.h"
#import <BmobSDK/Bmob.h>
#import <SVProgressHUD.h>
@interface DuiHuanTableViewController ()
@property (nonatomic,copy)NSMutableArray *dataArr;
@end

@implementation DuiHuanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArr = [NSMutableArray array];
    self.title = @"功德兑换";
    [SVProgressHUD show];
    [self.tableView registerNib:[UINib nibWithNibName:@"DuHuanTableViewCell" bundle:nil] forCellReuseIdentifier:@"css"];
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"Gifts"];
    //查找GameScore表的数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        for (BmobObject *obj in array) {
            [self->_dataArr addObject:obj];
        }
        [SVProgressHUD dismiss];
            [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    if(_dataArr.count%2 == 0){
        return _dataArr.count/2;
    }else{
        return _dataArr.count/2+1;
    }
    return 0;
}

-(UIImage *)Base64StrToUIImage:(NSString *)_encodedImageStr

{

    NSData *_decodedImageData   = [[NSData alloc] initWithBase64Encoding:_encodedImageStr];

    UIImage *_decodedImage      = [UIImage imageWithData:_decodedImageData];

    return _decodedImage;

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger num = 2*indexPath.row;
    DuHuanTableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"css"];
    BmobObject *b= _dataArr[num];
    // Configure the cell...
//    UIImage *img = [self Base64StrToUIImage:[b objectForKey:@"ImageBase"]];
    UIImage *img = [UIImage imageNamed:[b objectForKey:@"ImageBase"]];
    if(img){
        c.giftImg1.image = img;
    }else{
        c.giftImg1.image = [UIImage imageNamed:@"icon_no_place"];
    }
    c.selectionStyle = UITableViewScrollPositionNone;
    c.giftTitleLb1.text = [NSString stringWithFormat:@"%@",[b objectForKey:@"giftTitle"]];
    c.gdLb1.text = [NSString stringWithFormat:@"功德值:%@",[b objectForKey:@"GDPay"]];
    c.mainB1 = _dataArr[num];;
    [c.giftDHBtn1 addTarget:self action:@selector(goToDetail1:) forControlEvents:UIControlEventTouchUpInside];
    if(num+1<_dataArr.count){
        c.giftView2.hidden = false;
        BmobObject *b2= _dataArr[num+1];
//        UIImage *img2 = [self Base64StrToUIImage:[b2 objectForKey:@"ImageBase"]];
        UIImage *img2 = [UIImage imageNamed:[b2 objectForKey:@"ImageBase"]];
        if(img2){
            c.giftImg2.image = img2;
        }else{
            c.giftImg2.image = [UIImage imageNamed:@"icon_no_place"];
        }
        
        c.gdLb2.text = [NSString stringWithFormat:@"功德值:%@",[b2 objectForKey:@"GDPay"]];
        c.giftTitleLb2.text = [NSString stringWithFormat:@"%@",[b2 objectForKey:@"giftTitle"]];
        c.mainB2 = _dataArr[num+1];
        [c.giftDHBtn2 addTarget:self action:@selector(goToDetail2:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        c.giftView2.hidden = true;
    }
    
    return c;
}

-(void)goToDetail1:(UIButton *)b{
    DuHuanTableViewCell *c = b.superview.superview.superview;
    
    DHDetailViewController *d = [[DHDetailViewController alloc] initWithNibName:@"DHDetailViewController" bundle:nil];
    d.mainB = c.mainB1;
    [self.navigationController pushViewController:d animated:true];
}

-(void)goToDetail2:(UIButton *)b{
    DuHuanTableViewCell *c = b.superview.superview.superview;
    
    DHDetailViewController *d = [[DHDetailViewController alloc] initWithNibName:@"DHDetailViewController" bundle:nil];
    d.mainB = c.mainB2;
    [self.navigationController pushViewController:d animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 270;
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
