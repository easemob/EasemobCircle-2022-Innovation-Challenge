//
//  MOFSAddressPickerView.m
//  MOFSPickerManager
//
//  Created by lzqhoh@163.com on 16/8/31.
//  Copyright © 2019年 luoyuan. All rights reserved.
//

#import "MOFSWishTypePickerView.h"

@interface MOFSWishTypePickerView() <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSArray *smallwisharray;
@property (nonatomic, strong) NSArray *bigwishtypes;
@property (nonatomic, strong) NSMutableArray *smallwishtypes;

@property (nonatomic, assign) BOOL isGettingData;
@property (nonatomic, strong) void (^getDataCompleteBlock)();

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation MOFSWishTypePickerView

@synthesize bigType=_bigType;
@synthesize smallType = _smallType;


#pragma mark - create UI

- (instancetype)initWithFrame:(CGRect)frame {
	
	self.semaphore = dispatch_semaphore_create(1);
	
	[self initToolBar];
	[self initContainerView];
	
	CGRect initialFrame;
	if (CGRectIsEmpty(frame)) {
		initialFrame = CGRectMake(0, self.toolBar.frame.size.height, UISCREEN_WIDTH, 216);
	} else {
		initialFrame = frame;
	}
	self = [super initWithFrame:initialFrame];
	if (self) {
		self.backgroundColor = [UIColor whiteColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		self.delegate = self;
		self.dataSource = self;
		[self initBgView];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self initWishTypeArray];
			[self getData];
			self.bigType = self.bigwishtypes[0];
			self.smallType = self.smallwishtypes[0];
			dispatch_queue_t queue = dispatch_queue_create("my.current.queue", DISPATCH_QUEUE_CONCURRENT);
			dispatch_barrier_async(queue, ^{
				dispatch_async(dispatch_get_main_queue(), ^{
					[self reloadAllComponents];
				});
			});
		});
	}
	return self;
}

- (void)initToolBar {
	self.toolBar = [[MOFSToolbar alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 44)];
	self.toolBar.translucent = NO;
}

- (void)initContainerView {
	self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT)];
	self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
	self.containerView.userInteractionEnabled = YES;
	[self.containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenWithAnimation)]];
}

- (void)initBgView {
	self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, UISCREEN_HEIGHT - self.frame.size.height - 44, UISCREEN_WIDTH, self.frame.size.height + self.toolBar.frame.size.height)];
}

#pragma mark - Action

- (void)showMOFSWishTypePickerCommitBlock:(void(^)(NSString *type1, NSString *type2))commitBlock cancelBlock:(void(^)())cancelBlock {
	[self showWithAnimation];
	
	__weak typeof(self) weakSelf = self;
	self.toolBar.cancelBlock = ^ {
		if (cancelBlock) {
			[weakSelf hiddenWithAnimation];
			cancelBlock();
		}
	};
	self.toolBar.commitBlock = ^ {
		if (commitBlock) {
			[weakSelf hiddenWithAnimation];
			NSString *ttype1;
			NSString *ttype2;
			ttype1 = _bigType[0];
			ttype2 = _smallType[0];
			// address = [NSString stringWithFormat:@"%@-%@-%@", _locate.state, _locate.city, _locate.district];
			commitBlock(ttype1, ttype2);
		}
	};
}

- (void)showWithAnimation {
	[self addViews];
	self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
	CGFloat height = self.bgView.frame.size.height;
	self.bgView.center = CGPointMake(UISCREEN_WIDTH / 2, UISCREEN_HEIGHT + height / 2);
	[UIView animateWithDuration:0.25 animations:^{
		self.bgView.center = CGPointMake(UISCREEN_WIDTH / 2, UISCREEN_HEIGHT - height / 2);
		self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
	}];
	
}

- (void)hiddenWithAnimation {
	CGFloat height = self.bgView.frame.size.height;
	[UIView animateWithDuration:0.25 animations:^{
		self.bgView.center = CGPointMake(UISCREEN_WIDTH / 2, UISCREEN_HEIGHT + height / 2);
		self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
	} completion:^(BOOL finished) {
		[self hiddenViews];
	}];
}

- (void)addViews {
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	[window addSubview:self.containerView];
	[window addSubview:self.bgView];
	[self.bgView addSubview:self.toolBar];
	[self.bgView addSubview:self];
}

- (void)hiddenViews {
	[self removeFromSuperview];
	[self.toolBar removeFromSuperview];
	[self.bgView removeFromSuperview];
	[self.containerView removeFromSuperview];
}

- (void)getData {
	self.isGettingData = YES;
	@try {
		[self getArrayByID:@"1"];
		self.isGettingData = NO;
		if (self.getDataCompleteBlock) {
			self.getDataCompleteBlock();
		}
	} @catch (NSException *exception) {
		
	} @finally {
		
	}
}


#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	switch (component) {
		case 0:
			return [self.bigwishtypes count];
		case 1:
			return [self.smallwishtypes count];
		default:
			return 0;
	}
	
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	switch (component) {
		case 0:
			return self.bigwishtypes[row][0];
		case 1:
			return self.smallwishtypes[row][0];
		default:
			return  @"";
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	switch (component) {
		case 0:
			self.bigType = self.bigwishtypes[row];
			[self getArrayByID:self.bigType[1]];
			self.smallType = self.smallwishtypes[0];
			[pickerView reloadComponent:1];
			[pickerView selectRow:0 inComponent:1 animated:YES];
			break;
		case 1:
			self.smallType = self.smallwishtypes[row];
			break;
		default:
			break;
	}
}

- (void)dealloc {
	self.bigType = nil;
	self.smallType = nil;
	self.smallwishtypes = nil;
	self.bigwishtypes = nil;
	self.smallwisharray = nil;
}

-(void)initWishTypeArray {
//    self.bigwishtypes = @[@[@"戒杀生",@"1"],@[@"戒偷盗",@"2"],@[@"戒贪婪",@"3"],@[@"戒邪淫",@"4"],@[@"戒妄语",@"5"],@[@"戒妄行",@"6"],@[@"戒不孝",@"7"],@[@"戒口欲",@"8"],@[@"戒自毁",@"9"],@[@"戒毁财",@"10"],@[@"戒网瘾",@"11"]];
//    self.smallwishtypes = [NSMutableArray array];
//    self.smallwisharray = @[@[@"戒杀戮众生",@"1"],@[@"戒残害众生",@"1"],@[@"戒遇杀不责",@"1"],@[@"戒见死不救",@"1"],@[@"戒偷盗他财",@"2"],@[@"戒抢夺他财",@"2"],@[@"戒得金不还",@"2"],@[@"戒借物不还",@"2"],@[@"戒妒人所有",@"3"],@[@"戒收人贿物",@"3"],@[@"戒见钱眼开",@"3"],@[@"戒占为己有",@"3"],@[@"戒邪恶妄想",@"4"],@[@"戒沉沦苦情",@"4"],@[@"戒违背伦理",@"4"],@[@"戒私下自渎",@"4"],@[@"戒胡言秽语",@"5"],@[@"戒背后议论",@"5"],@[@"戒轻薄隐私",@"5"],@[@"戒嗔言疑人",@"5"],@[@"戒轻慢他人",@"6"],@[@"戒辱亵他人",@"6"],@[@"戒打架斗殴",@"6"],@[@"戒自毁三宝",@"6"],@[@"戒不孝父母",@"7"],@[@"戒不孝长辈",@"7"],@[@"戒不尊兄长",@"7"],@[@"戒不护幼小",@"7"],@[@"戒沉迷烟瘾",@"8"],@[@"戒沉迷酒瘾",@"8"],@[@"戒贪恋美食",@"8"],@[@"戒不律零食",@"8"],@[@"戒沉迷毒瘾",@"9"],@[@"戒自轻自残",@"9"],@[@"戒自轻自杀",@"9"],@[@"戒妄自轻生",@"9"],@[@"戒沉迷赌博",@"10"],@[@"戒贪恋快财",@"10"],@[@"戒小人说服",@"10"],@[@"戒不存钱财",@"10"],@[@"戒沉迷游戏",@"11"],@[@"戒网络社交",@"11"],@[@"戒沉迷手机",@"11"],@[@"戒网络赌博",@"11"]];
    self.bigwishtypes = @[@[@"吉祥运气",@"1"],@[@"财富物品",@"10"],@[@"爱情缘分",@"4"],@[@"幸福开心",@"2"],@[@"学业晋升",@"3"],@[@"事业成就",@"5"],@[@"亲情友情",@"6"],@[@"平安放心",@"7"],@[@"琐事化解",@"8"],@[@"健康安逸",@"9"]];
    self.smallwishtypes = [NSMutableArray array];
    self.smallwisharray = @[@[@"心想事成",@"1"],@[@"奇迹发生",@"1"],@[@"步入正轨",@"3"],@[@"考试通过",@"3"],@[@"榜上有名",@"3"],@[@"开心快乐",@"2"],@[@"得到友情",@"6"],@[@"找好工作",@"5"],@[@"工作顺利",@"5"],@[@"财源滚滚",@"10"],@[@"缘分到来",@"4"],@[@"追求成功",@"4"],@[@"回心转意",@"4"],@[@"永远幸福",@"2"],@[@"爱情美满",@"4"],@[@"婚姻幸福",@"4"],@[@"美好未来",@"2"],@[@"出行平安",@"7"],@[@"亲友平安",@"7"],@[@"家人平安",@"7"],@[@"一生平安",@"7"],@[@"误会化解",@"8"],@[@"仇怨化解",@"8"],@[@"健康成长",@"9"],@[@"疾病痊愈",@"9"],@[@"白头偕老",@"4"],@[@"早生贵子",@"2"],@[@"收入丰厚",@"10"],@[@"财运亨通",@"10"],@[@"鸿运当头",@"1"],@[@"大吉大利",@"1"],@[@"步步高升",@"5"],@[@"事业有成",@"5"],@[@"学业有成",@"3"],@[@"早日成才",@"3"],@[@"得到亲情",@"6"],@[@"健康长寿",@"9"],@[@"安享晚年",@"9"],@[@"友谊常存",@"6"],@[@"新置物件",@"10"],@[@"奢侈物品",@"10"],@[@"情深义重",@"6"],@[@"亲情无限",@"6"],@[@"去除烦恼",@"8"],@[@"清除霉运",@"1"]];
}

-(void)getArrayByID:(NSString*)aID{
	if(aID <= 0)
		return;
	[self.smallwishtypes removeAllObjects];
	for(int i = 0; i < self.smallwisharray.count; i++){
		if([self.smallwisharray[i][1] isEqualToString:aID]){
			[self.smallwishtypes addObject:self.smallwisharray[i]];
		}
	}
}

@end
