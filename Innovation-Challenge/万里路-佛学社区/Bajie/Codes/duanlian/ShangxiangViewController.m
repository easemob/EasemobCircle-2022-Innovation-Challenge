//
//  ShangxiangViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/9/23.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "ShangxiangViewController.h"
#import <SVProgressHUD.h>
#import "LocalItem.h"
#import "XianghuoViewController.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import "tooles.h"

@interface ShangxiangViewController ()

@property(nonatomic,strong) UIImageView *bgView;
@property(nonatomic,strong) UIImageView *foLightView;
@property(nonatomic,strong) UIImageView *foView;
@property(nonatomic,strong) UIImageView *smokeView;
@property(nonatomic,strong) UIImageView *stoveView;
@property(nonatomic,strong) UILabel *stoveLabel;

@property(nonatomic,strong) UIButton *gongdexiangButton;
@property(nonatomic,strong) UIImageView *xiangView;
@property(nonatomic,strong) UILabel *xiangLabel;
@property(nonatomic,strong) UIButton *stoveButton;
@property(nonatomic,strong) UILabel *moneyLabel;
@property(nonatomic,strong) NSString *moneytext;

@end

@implementation ShangxiangViewController

@synthesize smokeView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lifo_bg.png"]];
        self.bgView.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:self.bgView];
        
        self.wishLabel = [[UILabel alloc]init];
        self.wishLabel.text = @"";
        self.wishLabel.numberOfLines = 0;
        self.wishLabel.textColor = [UIColor yellowColor];
        self.wishLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0f];
        self.wishLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.wishLabel];
        
        
        self.foLightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xiuxing_lifo_circle_light"]];
        self.foLightView.contentMode = UIViewContentModeScaleAspectFit;
        [self.foLightView setFrame:CGRectMake(0, 0, kDeviceWidth/2, kDeviceWidth/2)];
        [self.view addSubview:self.foLightView];
        
        self.foView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guanyinpusa.png"]];
        self.foView.contentMode = UIViewContentModeScaleAspectFit;
        [self.foView setFrame:CGRectMake(0, 0, kDeviceWidth/2, kDeviceWidth/2)];
        [self.view addSubview:self.foView];
        
        self.stoveView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xiuxing_xiang"]];
        self.stoveView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.stoveView];
        
        self.stoveLabel = [UILabel new];
        self.stoveLabel.text = @"点此上香";
        self.stoveLabel.textColor = [UIColor whiteColor];
        self.stoveLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
        self.stoveLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.stoveLabel];
        
        self.smokeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fotang_xiang1"]];
        self.smokeView.animationImages = @[[UIImage imageNamed:@"fotang_xiang1"],[UIImage imageNamed:@"fotang_xiang2"],[UIImage imageNamed:@"fotang_xiang3"]];
        smokeView.animationDuration = 1.0f;
        smokeView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.smokeView];
        
        self.xiangView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag0"]];
        [self.view addSubview:self.xiangView];
        
        self.xiangLabel = [UILabel new];
        self.xiangLabel.text = @"";
        self.xiangLabel.numberOfLines = 0;
        self.xiangLabel.textColor = [UIColor yellowColor];
        self.xiangLabel.font = [UIFont fontWithName:@"Arial" size:33.0f];
        self.xiangLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.xiangLabel];
        
        self.gongdexiangButton = [[UIButton alloc] init];
        [self.gongdexiangButton setImage:[UIImage imageNamed:@"donate_box"] forState:UIControlStateNormal];
        self.gongdexiangButton.hidden = true;
        [self.view addSubview:self.gongdexiangButton];
        
        self.moneytext = @"8元";
        self.moneyLabel = [UILabel new];
        [self.moneyLabel setTextColor:[UIColor whiteColor]];
        [self.moneyLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        self.moneyLabel.textAlignment = NSTextAlignmentCenter;
        self.moneyLabel.numberOfLines = 0;
        self.moneyLabel.text = @"点选功德箱\n进行捐献";
        self.moneyLabel.hidden = true;
        [self.view addSubview:self.moneyLabel];
        
        self.stoveButton = [UIButton new];
        [self.stoveButton addTarget:self action:@selector(stovePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.stoveButton.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.stoveButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    WS(ws);
    //TODO use masonry to re-frame all the subviews.
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view);
    }];
    
    [self.foLightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kDeviceWidth*2/3);
        make.height.mas_equalTo(kDeviceWidth*2/3);
        make.centerX.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(ws.view.mas_centerY).with.offset(KDeviceHeight/11);
    }];
    
    [self.foView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kDeviceWidth*2/3);
        make.height.mas_equalTo(kDeviceWidth*2/3);
        make.centerX.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(ws.view.mas_centerY).with.offset(KDeviceHeight/11);
    }];
    
    [self.wishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kDeviceWidth*4/5);
        make.height.mas_equalTo(kDeviceWidth*1/3);
        make.centerX.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(_foLightView.mas_top);
        make.top.mas_equalTo(ws.view.mas_top);
    }];
    
    [self.stoveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kDeviceWidth/5);
        make.height.mas_equalTo(kDeviceWidth/5);
        make.centerX.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(ws.view.mas_centerY).with.offset(KDeviceHeight * 2/9);
    }];
    
    [self.stoveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(ws.view);
        make.height.mas_equalTo(30);
        make.centerX.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.stoveView.mas_bottom);
    }];
    
    [self.smokeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kDeviceWidth*2/3);
        make.height.mas_equalTo(kDeviceWidth*4/9);
        make.centerX.mas_equalTo(ws.view);
        make.bottom.mas_equalTo(ws.stoveView.mas_top);
    }];
    
    [self.xiangView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.xiangView.intrinsicContentSize);
        make.right.mas_equalTo(ws.view.mas_right);
        make.top.mas_equalTo(self.stoveView.mas_top);
    }];
    
    [self.xiangLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.xiangView.frame.size);
        make.centerX.mas_equalTo(self.xiangView.mas_centerX);
        make.centerY.mas_equalTo(self.xiangView.mas_centerY).with.offset(-5);
    }];
    
    [self.gongdexiangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.gongdexiangButton.intrinsicContentSize);
        make.left.mas_equalTo(ws.view.mas_left);
        make.bottom.mas_equalTo(ws.view.mas_bottom);
    }];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.gongdexiangButton.intrinsicContentSize.width ,40));
        make.left.mas_equalTo(ws.view.mas_left);
        make.bottom.mas_equalTo(self.gongdexiangButton.mas_top).with.offset(-10);
    }];
    
    [self.stoveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.gongdexiangButton.mas_right);
        make.right.mas_equalTo(ws.view.mas_right);
        make.bottom.mas_equalTo(ws.view.mas_bottom);
        make.top.mas_equalTo(self.stoveView.mas_top).with.offset(-self.stoveView.intrinsicContentSize.height);
    }];
    
    [self setXiangHuo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.smokeView stopAnimating];
}

-(void)setXiangHuo{
    NSLog(@"FFFFFFFFFFFFF:%i",APPALL.myLocalItem.xiangkind);
    if(APPALL.myLocalItem.xiangkind == 0){
        self.smokeView.hidden = YES;
        self.stoveView.image = [UIImage imageNamed:@"xiuxing_xiang"];
        self.xiangView.hidden = YES;
    }else{
        double intervalTime = [[NSDate date] timeIntervalSinceReferenceDate] - [APPALL.myLocalItem.xiangtime timeIntervalSinceReferenceDate];
        //1天 6种动画， 60 * 60 * 24 / 6
        NSInteger seconds = (NSInteger)intervalTime / 14400;
        NSLog(@"seconds:%ld",(long)seconds);
        if(seconds >= 6 || seconds < 0){
            self.smokeView.hidden = YES;
            self.stoveView.image = [UIImage imageNamed:@"xiuxing_xiang"];
            self.xiangView.hidden = YES;
            return;
        }
        self.smokeView.hidden = NO;
        self.xiangView.hidden = NO;
        self.stoveView.image = [UIImage imageNamed:@"xiuxing_xiang_zengyuan"];
        self.xiangLabel.text = [tooles getLabelFromIndex:APPALL.myLocalItem.xiangkind];
        if ([self.xiangLabel.text isEqualToString:@"清\n香"]){
            self.wishLabel.text = @"随忙随闲不离弥陀名号，顺境逆境不忘往生西方。恭祝天天快乐日日精进!";
        }else if ([self.xiangLabel.text isEqualToString:@"平\n安"]){
            self.wishLabel.text = @"大肚能容，断却许多烦恼障;笑容可掬，结成无量欢喜缘。愿您在新年里广种福田，广结善缘，幸福与快乐常在!";
        }else if ([self.xiangLabel.text isEqualToString:@"高\n升"]){
            self.wishLabel.text = @"阿弥陀佛!愿您生生世世，不迷正路修行;直取菩提上果，遍度法界众生。万事吉祥安康！";
        }else if ([self.xiangLabel.text isEqualToString:@"祈\n福"]){
            self.wishLabel.text = @"愿佛光普照，法喜充满!愿三宝加持，福慧双收!更上一层楼，早登无上觉，时时心清净，日日事吉祥!";
        }else if ([self.xiangLabel.text isEqualToString:@"鸿\n运"]){
            self.wishLabel.text = @"愿昼吉祥夜吉祥，昼夜六时恒吉祥，一切时中吉祥者，愿诸三宝哀摄受。";
        }else if ([self.xiangLabel.text isEqualToString:@"长\n寿"]){
            self.wishLabel.text = @"年复一年无量寿，月又一月琉璃光，日日夜夜观自在，时时刻刻妙吉祥。祝长寿多福！";
        }else if ([self.xiangLabel.text isEqualToString:@"就\n业"]){
            self.wishLabel.text = @"凛冽的清风和温暖的阳光同在!愿慈悲的法流滋润您的未来，原智慧的光明给你带来事业的成功!愿六时吉祥!";
        }else if ([self.xiangLabel.text isEqualToString:@"姻\n缘"]){
            self.wishLabel.text = @"情重意重，情意重重，佛缘修意缘广结善缘，对面相谈是有缘，再而相见是天缘，今生相聚前世缘，互相关心要惜缘!三吉祥即三藐三菩提心!";
        }else if ([self.xiangLabel.text isEqualToString:@"求\n子"]){
            self.wishLabel.text = @"愿佛法的人生伴随你;观音的慈悲充满你;文殊的智慧带领你;地藏的愿心加持你，普贤的行愿成就你!愿你在佛菩萨的加持下一切如意。合十敬祝，家家吉祥，一切圆满。";
        }else if ([self.xiangLabel.text isEqualToString:@"去\n病"]){
            self.wishLabel.text = @"身体安康，违缘消灭，顺缘增长，广闻深思，勤修佛法，六时吉祥!";
        }else if ([self.xiangLabel.text isEqualToString:@"学\n业"]){
            self.wishLabel.text = @"愿你的法喜如雨，带来智慧甘露;愿你菩提心似火，焚烧一切烦恼;愿你的无尽的智慧，带来无尽的前途!愿你我生生世世长相逢，同行同愿同圆种智功德海。";
        }else if ([self.xiangLabel.text isEqualToString:@"圆\n满"]){
            self.wishLabel.text = @"凛冽的清风和温暖的阳光同在！愿慈悲的法流滋润您的未来，愿智慧的光明照耀您的身心！愿您成就智慧般若，功德大圆满，诸事大圆满！";
        }
        
        [self.smokeView startAnimating];
    }
}

//-(void)gongdePressed:(id)sender{
//    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"功德箱" message:@"随缘乐助，广种福田。\n施财得福，扬善积德。\n我愿捐献：" preferredStyle:UIAlertControllerStyleAlert];
//    //    vc.view.backgroundColor = [UIColor goldColor];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    UIAlertAction *ok1Action = [UIAlertAction actionWithTitle:@"1功德" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        [self gongdeIAP:@"1元"];
//    }];
//    UIAlertAction *ok8Action = [UIAlertAction actionWithTitle:@"8功德" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        [self gongdeIAP:@"8元"];
//    }];
//    UIAlertAction *ok50Action = [UIAlertAction actionWithTitle:@"50功德" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        [self gongdeIAP:@"50元"];
//    }];
//    UIAlertAction *ok98Action = [UIAlertAction actionWithTitle:@"98功德" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        [self gongdeIAP:@"98元"];
//    }];
//    UIAlertAction *ok298Action = [UIAlertAction actionWithTitle:@"298功德" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        [self gongdeIAP:@"298元"];
//    }];
//    [vc addAction:ok1Action];
//    [vc addAction:ok8Action];
//    [vc addAction:ok50Action];
//    [vc addAction:ok98Action];
//    [vc addAction:ok298Action];
//    [vc addAction:cancelAction];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentViewController:vc animated:NO completion:nil];
//    });
//}

-(void)gongdeIAP:(NSString*)moneyStr {
    [SVProgressHUD showWithStatus:@"请稍候..."];
    self.moneytext = moneyStr;
    APPALL.myIAPDelegate = self;
    NSString *iapID = [tooles getIAPIDByPriceStr:self.moneytext payKind:EPayFN];
    [APPALL startToIAP:iapID];
}

-(void)stovePressed:(id)sender{
    XianghuoViewController *vc = [XianghuoViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)VCIAPSucceed:(NSString*)aSucc{
    [SVProgressHUD dismiss];
//    [tooles addHonor:self.moneytext];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"有求必应" message:@"捐献功德成功。\n愿施主功德圆满，前途无量！\n南无阿弥陀佛！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)VCIAPFailed:(NSString*)aSucc{
    [SVProgressHUD dismiss];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:aSucc preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

@end
