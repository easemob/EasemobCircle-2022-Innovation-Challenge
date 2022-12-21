//
//  GuanyuViewController.m
//  Xuefoqifu
//
//  Created by MingmingSun on 16/10/5.
//  Copyright © 2019年 Sunmingming. All rights reserved.
//

#import "GuanyuViewController.h"
#import "AppDelegate.h"
#import <Masonry.h>

@interface GuanyuViewController ()

@property(nonatomic,strong) UITextView *myTextview;

@end

@implementation GuanyuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.myTextview = [UITextView new];
        self.myTextview.editable = NO;
        self.myTextview.selectable = NO;
        [self.view addSubview:self.myTextview];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"声明";
    self.myTextview.text = @"“学佛祈福”尊重并保护所有使用服务用户的个人隐私权。为了给您提供更准确、更有个性化的服务，“学佛祈福”会按照本隐私权政策的规定使用和披露您的个人信息。但“学佛祈福”将以高度的勤勉、审慎义务对待这些信息。除本隐私权政策另有规定外，在未征得您事先许可的情况下，“学佛祈福”不会将这些信息对外披露或向第三方提供。“学佛祈福”会不时更新本隐私权政策。 您在同意“学佛祈福”服务使用协议之时，即视为您已经同意本隐私权政策全部内容。本隐私权政策属于“学佛祈福”服务使用协议不可分割的一部分。\n1.适用范围\na) 在您使用“学佛祈福”时，您根据“学佛祈福”要求提供的个人注册信息；\nb) 在您使用“学佛祈福”网络服务，或访问“学佛祈福”平台网页时，“学佛祈福”自动接收并记录的您的浏览器和计算机上的信息，包括但不限于您的IP地址、浏览器的类型、使用的语言、访问日期和时间、软硬件特征信息及您需求的网页记录等数据；\nc) “学佛祈福”通过合法途径从商业伙伴处取得的用户个人数据。\n您了解并同意，以下信息不适用本隐私权政策：\na) 您在使用“学佛祈福”平台提供的搜索服务时输入的关键字信息；\nb) “学佛祈福”收集到的您在“学佛祈福”发布的有关信息数据，包括但不限于参与活动、成交信息及评价详情；\nc) 违反法律规定或违反“学佛祈福”规则行为及“学佛祈福”已对您采取的措施。\n2.信息使用\na) “学佛祈福”不会向任何无关第三方提供、出售、出租、分享或交易您的个人信息，除非事先得到您的许可，或该第三方和“学佛祈福”（含“学佛祈福”关联公司）单独或共同为您提供服务，且在该服务结束后，其将被禁止访问包括其以前能够访问的所有这些资料。\nb) “学佛祈福”亦不允许任何第三方以任何手段收集、编辑、出售或者无偿传播您的个人信息。任何“学佛祈福”平台用户如从事上述活动，一经发现，“学佛祈福”有权立即终止与该用户的服务协议。\nc) 为服务用户的目的，“学佛祈福”可能通过使用您的个人信息，向您提供您感兴趣的信息，包括但不限于向您发出产品和服务信息，或者与“学佛祈福”合作伙伴共享信息以便他们向您发送有关其产品和服务的信息（后者需要您的事先同意）。\n3.信息披露\n在如下情况下，“学佛祈福”将依据您的个人意愿或法律的规定全部或部分的披露您的个人信息：\na) 经您事先同意，向第三方披露；\nb) 为提供您所要求的产品和服务，而必须和第三方分享您的个人信息；\nc) 根据法律的有关规定，或者行政或司法机构的要求，向第三方或者行政、司法机构披露；\nd) 如您出现违反中国有关法律、法规或者“学佛祈福”服务协议或相关规则的情况，需要向第三方披露；\ne) 如您是适格的知识产权投诉人并已提起投诉，应被投诉人要求，向被投诉人披露，以便双方处理可能的权利纠纷；\nf) 在“学佛祈福”平台上创建的某一交易中，如交易任何一方履行或部分履行了交易义务并提出信息披露请求的，“学佛祈福”有权决定向该用户提供其交易对方的联络方式等必要信息，以促成交易的完成或纠纷的解决。\ng) 其它“学佛祈福”根据法律、法规或者网站政策认为合适的披露。\n4. Cookie的使用\na) 在您未拒绝接受cookies的情况下，“学佛祈福”会在您的计算机上设定或取用cookies，以便您能登录或使用依赖于cookies的“学佛祈福”平台服务或功能。“学佛祈福”使用cookies可为您提供更加周到的个性化服务，包括推广服务。  b)您有权选择接受或拒绝接受cookies。您可以通过修改浏览器设置的方式拒绝接受cookies。但如果您选择拒绝接受cookies，则您可能无法登录或使用依赖于cookies的“学佛祈福”网络服务或功能。\nc) 通过“学佛祈福”所设cookies所取得的有关信息，将适用本政策。\n6.信息安全\na) “学佛祈福”信息均有安全保护功能，请妥善保管您账户信息。“学佛祈福”将通过加密等安全措施确保您的信息不丢失，不被滥用和变造。尽管有前述安全措施，但同时也请您注意在信息网络上不存在“完善的安全措施”。\nb) 在使用“学佛祈福”网络服务进行网上交易时，您不可避免的要向交易对方或潜在的交易对方披露自己的个人信息，如联络方式或者邮政地址。请您妥善保护自己的个人信息，仅在必要的情形下向他人提供。如您发现自己的个人信息泄密，尤其是“学佛祈福”账户信息发生泄露，请您立即联络“学佛祈福”客服，以便“学佛祈福”采取相应措施。\n客服邮箱:chenjinyue1016@163.com";
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    WS(ws);
    
    [self.myTextview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    self.myTextview.font = [UIFont fontWithName:@"Arial" size:16.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
