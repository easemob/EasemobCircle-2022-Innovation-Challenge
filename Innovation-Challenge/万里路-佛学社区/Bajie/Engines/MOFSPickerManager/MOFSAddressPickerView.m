//
//  MOFSAddressPickerView.m
//  MOFSPickerManager
//
//  Created by lzqhoh@163.com on 16/8/31.
//  Copyright © 2019年 luoyuan. All rights reserved.
//

#import "MOFSAddressPickerView.h"

@interface MOFSAddressPickerView() <UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *provinces, *cities, *areas;
}

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, assign) BOOL isGettingData;
@property (nonatomic, strong) void (^getDataCompleteBlock)();

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation MOFSAddressPickerView

@synthesize locate=_locate;


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
        
        self.locate = [[HZLocation alloc] init];
        [self initBgView];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self getData];
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

- (void)showMOFSAddressPickerCommitBlock:(void(^)(NSString *address, NSString *zipcode))commitBlock cancelBlock:(void(^)())cancelBlock {
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
            NSString *address;
            NSString *zipcode;
            address = [NSString stringWithFormat:@"%@-%@-%@", _locate.state, _locate.city, _locate.district];
            commitBlock(address, zipcode);
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
        provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
        cities = [[provinces objectAtIndex:0] objectForKey:@"cities"];
        self.locate.state = [[provinces objectAtIndex:0] objectForKey:@"state"];
        self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
        areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
        if (areas.count > 0) {
            self.locate.district = [areas objectAtIndex:0];
        } else{
            self.locate.district = @"";
        }
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
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [provinces count];
        case 1:
            return [cities count];
        case 2:
            return [areas count];
        default:
            return 0;
    }

}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [[provinces objectAtIndex:row] objectForKey:@"state"];
        case 1:
            return [[cities objectAtIndex:row] objectForKey:@"city"];
        case 2:
            if ([areas count] > 0) {
                return [areas objectAtIndex:row];
            }
        default:
            return  @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
            cities = [[provinces objectAtIndex:row] objectForKey:@"cities"];
            areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
            
            self.locate.state = [[provinces objectAtIndex:row] objectForKey:@"state"];
            self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
            if ([areas count] > 0) {
                self.locate.district = [areas objectAtIndex:0];
            } else{
                self.locate.district = @"";
            }
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            break;
        case 1:
            areas = [[cities objectAtIndex:row] objectForKey:@"areas"];
            
            self.locate.city = [[cities objectAtIndex:row] objectForKey:@"city"];
            if ([areas count] > 0) {
                self.locate.district = [areas objectAtIndex:0];
            } else{
                self.locate.district = @"";
            }
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            break;
        case 2:
            if ([areas count] > 0) {
                self.locate.district = [areas objectAtIndex:row];
            } else{
                self.locate.district = @"";
            }
            break;
        default:
            break;
    }
}

- (void)dealloc {
    _locate = nil;
    provinces = nil;
}

@end
