
#import "PellTableViewSelect.h"
#import "UIViewController+Util.h"
#import <Masonry.h>
#import "EMDefines.h"
#import "EMColorDefine.h"
#define  LeftView 10.0f
#define  TopToView 10.0f
@interface  PellTableViewSelect()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,copy) NSArray *selectData;
@property (nonatomic,copy) void(^action)(NSInteger index);
@property (nonatomic,copy) NSArray * imagesData;
@end



PellTableViewSelect * backgroundView;
UITableView * tableView;

@implementation PellTableViewSelect


- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

+ (void)addPellTableViewSelectWithWindowFrame:(CGRect)frame
                                   selectData:(NSArray *)selectData
                                       images:(NSArray *)images
                                       locationY:(CGFloat)locationY
                                       action:(void(^)(NSInteger index))action animated:(BOOL)animate
{
    if (backgroundView != nil) {
        [PellTableViewSelect hiden];
    }
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    
    backgroundView = [[PellTableViewSelect alloc] initWithFrame:win.bounds];
    backgroundView.action = action;
    backgroundView.imagesData = images ;
    backgroundView.selectData = selectData;
    backgroundView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    [win addSubview:backgroundView];

    // TAB
    //tableView = [[UITableView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - frame.size.width/2 - 15.0 , win.frame.size.height - frame.origin.y - 20 , frame.size.width, 52 * selectData.count) style:0];
    tableView = [[UITableView alloc]init];
    tableView.scrollEnabled = NO;
    tableView.dataSource = backgroundView;
//    tableView.transform =  CGAffineTransformMakeScale(0.5, 0.5);
    tableView.delegate = backgroundView;
    tableView.layer.cornerRadius = 10.0f;
    // ??????
    tableView.layer.anchorPoint = CGPointMake(1.0, 0);
    tableView.transform =CGAffineTransformMakeScale(0.0001, 0.0001);
    
    tableView.rowHeight = 52;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [win addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(win).offset(locationY);
        make.right.equalTo(win).offset(frame.size.width/2 - 13);
        make.width.equalTo(@(frame.size.width));
        make.height.equalTo(@(frame.size.height));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClick)];
    [backgroundView addGestureRecognizer:tap];
    backgroundView.action = action;
    backgroundView.selectData = selectData;
//    tableView.layer.anchorPoint = CGPointMake(100, 64);


    if (animate == YES) {
        backgroundView.alpha = 0;
//        tableView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 70, frame.size.width, 40 * selectData.count);
        [UIView animateWithDuration:0.3 animations:^{
            backgroundView.alpha = 0.5;
           tableView.transform = CGAffineTransformMakeScale(1.0, 1.0);
           
        }];
    }
}
+ (void)tapBackgroundClick
{
    [PellTableViewSelect hiden];
}
+ (void)hiden
{
    if (backgroundView != nil) {
        
        [UIView animateWithDuration:0.3 animations:^{
//            UIWindow * win = [[[UIApplication sharedApplication] windows] firstObject];
//            tableView.frame = CGRectMake(win.bounds.size.width - 35 , 64, 0, 0);
            tableView.transform = CGAffineTransformMakeScale(0.000001, 0.0001);
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
            [tableView removeFromSuperview];
            tableView = nil;
            backgroundView = nil;
        }];
    }
   
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selectData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"PellTableViewSelectIdentifier";
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:Identifier];
    }
    cell.imageView.image = [UIImage imageNamed:self.imagesData[indexPath.row]];
    cell.textLabel.text = _selectData[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.action) {
        self.action(indexPath.row);
    }
    [PellTableViewSelect hiden];
}
/*
#pragma mark ???????????????
- (void)drawRect:(CGRect)rect

{
    
    
    //    [colors[serie] setFill];
    // ???????????????
    [[UIColor whiteColor] set];
    //????????????????????????????????????
    
    CGContextRef  context = UIGraphicsGetCurrentContext();
    
    //??????path?????????????????????
    
    CGContextBeginPath(context);//??????
    CGFloat location = [UIScreen mainScreen].bounds.size.width;
    CGContextMoveToPoint(context,
                         location -  LeftView - 10, 70);//????????????
    
    CGContextAddLineToPoint(context,
                             location - 2*LeftView - 10 ,  60);
    
    CGContextAddLineToPoint(context,
                            location - TopToView * 3 - 10, 70);
    
    CGContextClosePath(context);//???????????????????????????????????????
    
    [[UIColor whiteColor] setFill];  //???????????????
    
    [[UIColor whiteColor] setStroke]; //??????????????????
    
    CGContextDrawPath(context,
                      kCGPathFillStroke);//????????????path
    
//    [self setNeedsDisplay];
}*/

@end
