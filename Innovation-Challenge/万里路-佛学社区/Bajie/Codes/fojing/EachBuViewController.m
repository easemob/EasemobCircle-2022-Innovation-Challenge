//
//  EachBuViewController.m
//  Xuefoqifu
//
//  Created by Mac on 2019/12/24.
//  Copyright © 2019 Sunmingming. All rights reserved.
//

#import "EachBuViewController.h"
#import "PCReaderViewController.h"
@interface EachBuViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property(nonatomic,copy)NSArray *mainArr;
@end

@implementation EachBuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
//    self.title = @"藏经阁目录";
    UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        [_mainTableView setTableFooterView:view];
    _mainArr = @[@[@"佛说法灭尽经",@"佛说戒香经",@"佛说九横经",@"佛说尸迦罗越六方礼经",@"佛说斋经",@"佛遗教经",@"三归五戒慈心厌离功德经",@"玉耶女经",@"增壹阿含经"],@[@"般若波罗密多心经",@"佛说摩呵般若波罗蜜多心经",@"金刚般若波罗蜜经",@"普遍智藏般若波罗蜜多心经"],@[@"佛说法华三昧经",@"佛说观普贤菩萨行法经",@"妙法莲华经观世音菩萨普门品",@"普贤十大行愿",@"萨昙分陀利经",@"无量义经"],@[@"阿弥陀鼓音声王陀罗尼经",@"八佛名号经",@"八吉祥经",@"大乘遍照光明藏无字法门经",@"佛说阿弥陀经",@"佛说八部佛名经",@"佛说八大菩萨经",@"佛说八吉祥神咒经",@"佛说八阳神咒经",@"佛说大乘稻杆经",@"佛说大乘流转诸有经",@"佛说大方等修多罗王经",@"佛说观无量寿佛经",@"佛说十吉祥经",@"佛说转有经",@"观无量寿佛经",@"过去庄严劫千佛名经",@"後出阿弥陀佛偈经",@"六菩萨亦当诵持经",@"外道问圣大乘法无我义经",@"维摩诘所说经",@"未来星宿劫千佛名经",@"现在贤劫千佛名经",@"银色女经",@"右绕佛塔功德经",@"盂兰盆经",@"浴佛功德经",@"造塔功德经",@"占察善恶业报经",@"长者法志妻经"],@[@"阿　世王问五逆经",@"阿难七梦经",@"阿难问事佛吉凶经",@"比丘避女恶名欲自杀经",@"布施经",@"采花违王上佛授决号妙花经",@"佛说孛经抄",@"佛说出家功德经",@"佛说出家缘经",@"佛说梵摩难国王经",@"佛说妇人遇辜经",@"佛说呵雕阿那　经",@"佛说进学经",@"佛说老女人经",@"佛说龙施女经",@"佛说轮转五道罪福报应经",@"佛说摩达国王经",@"佛说摩邓女经",@"佛说末罗王经",@"佛说譬喻经",@"佛说沙曷比丘功德经",@"佛说无常经（附_临终方诀）",@"佛说耶只经",@"佛说越难经",@"佛为阿支罗迦叶自化作苦经",@"佛为年少比丘说正事经",@"犍陀国王经",@"嗟{革蔑}曩法天子受三归依获免恶道经",@"慢法经",@"随念三宝经",@"无垢优婆夷问经",@"五母子经",@"长爪梵志请问经"],@[@"佛说戒消灾经",@"佛说菩萨内戒经",@"佛说十善业道经",@"三曼陀跋陀罗菩萨经"],@[@"大乐金刚不空真实三麽耶经",@"佛顶尊胜陀罗尼经",@"佛说大乘圣无量寿决定光明王如来陀罗尼经",@"佛说疗痔病经",@"佛说胜幡璎珞陀罗尼经",@"佛说延命地藏菩萨经",@"摩诃般若波罗蜜大明咒经",@"三十五佛名礼忏文",@"圣妙吉祥真实名经",@"文殊问经字母品第十四",@"药师琉璃光如来本愿功德经"],@[@"大乘方广总持经",@"佛说济诸方等学经"],@[@"八大人觉经",@"佛教中的神通",@"佛说八大人觉经",@"佛说父母恩重难报经",@"佛说观无量寿佛经2",@"佛说四十二章经",@"佛学基础知识",@"金刚般若波罗蜜经2",@"四十二章经",@"学佛是怎么一回事",@"赞僧功德经",@"增壹阿含经·安般品"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *a = _mainArr[_bookCount];
    return a.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
//    cell.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:170.0/255.0 blue:75.0/255.0 alpha:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *aa = _mainArr[_bookCount];
    cell.textLabel.text = aa[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *a = _mainArr[_bookCount];
    
//    NSURL *url = [[NSBundle mainBundle] URLForResource:a[indexPath.row] withExtension:@"txt"];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:a[indexPath.row] ofType:@"txt"];
    PCReaderViewController *reader = [[PCReaderViewController alloc] init];
//    [reader loadText:[NSString stringWithContentsOfURL:url encoding:NSWindowsCP1251StringEncoding error:nil]];
    NSError *error;
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *xml = [NSString stringWithContentsOfFile:jsonPath encoding:encode error:&error];
    
    if(xml == nil) {
        NSLog(@"Error reading url at %@", [error localizedFailureReason]);
    } else {
        [reader loadText:xml];
        reader.title = a[indexPath.row];
       [self.navigationController pushViewController:reader animated:YES];
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
