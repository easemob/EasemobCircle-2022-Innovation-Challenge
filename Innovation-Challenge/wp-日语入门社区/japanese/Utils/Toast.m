//
// Created by LYQ on 16/7/30.
// Copyright (c) 2020 LYQ. All rights reserved.
//

#import "Toast.h"

@interface Toast()

@end
static Toast *toast = nil;
NSTimer *timer1 = nil;
@implementation Toast

-(id)initWithMessage:(NSString *)message{
    if (self = [super init]){
        _message = [message copy];
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize cgSize = [_message sizeWithFont:font constrainedToSize:CGSizeMake(250,MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,cgSize.width+12,cgSize.height+12)];
        _label.backgroundColor = [UIColor clearColor];
        _label.text = _message;
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentRight;
        _label.font = font;
        _label.numberOfLines = 0;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,_label.frame.size.width,_label.frame.size.height)];
        _contentView.layer.cornerRadius = 5.0f;
        _contentView.layer.borderWidth = 1.0f;
        _contentView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
        _contentView.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.7f];
        [_contentView addSubview:_label];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _duration = TOAST_LENGTH_SHORT;
        _contentView.tag = CURRENT_TOAST_TAG;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:nil name:<#(NSString *)aName#> object:<#(id)anObject#>];
    }
    return self;
}

-(void)showAnimation{
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    _contentView.alpha = 1.0f;
    [UIView commitAnimations];
}

-(void)hideAnimation{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(dismissToast)];
    [UIView setAnimationDuration:0.3];
    _contentView.alpha = 0.0f;
    [UIView commitAnimations];
}
/**
 * 显示toast
 * @param message
 */
+ (void)show:(NSString *)message {
    if (!toast){
        toast = [[Toast alloc] initWithMessage:message];
    } else{
        [toast initWithMessage:message];
    }
    [toast show:message];
}
//+ (void)show:(NSString *)message, ... {
//    id eachmessage;
//    va_list messages;
//    if (message){
//        va_start(messages,message);
//        while ((eachmessage = va_arg(messages,id))){
//            if (eachmessage)
//            message = [message stringByAppendingString:eachmessage];
////            NSRange range = [message rangeOfString:@"%@"];
////            message = [message stringByReplacingCharactersInRange:range withString:eachmessage];
//        }
//    }
//    va_end(messages);
//    if (!toast){
//        toast = [[Toast alloc] initWithMessage:message];
//    } else{
//        [toast initWithMessage:message];
//    }
//    [toast show:message];
//}

-(void)show:(NSString *)message{
    UIView *currentToast = [[UIApplication sharedApplication].keyWindow viewWithTag:CURRENT_TOAST_TAG];
    if (currentToast != nil) {
        [currentToast removeFromSuperview];
    }
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:_contentView];
        _contentView.center = CGPointMake(SCREEN_WIDTH/2,SCREEN_HEIGHT-70);
        [self showAnimation];
    if (timer1){
        [timer1 invalidate];
    }
        timer1 = [NSTimer timerWithTimeInterval:((float)_duration)
                                              target:self selector:@selector(hideAnimation)
                                            userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
//        [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:_duration];
}
@end
