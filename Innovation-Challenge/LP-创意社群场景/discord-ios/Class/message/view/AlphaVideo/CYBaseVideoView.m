//
//  CYBaseVideoView.m
//  SVGAPlayer
//
//  Created by wang yu on 2022/5/16.
//  Copyright © 2022 Voice Yuan Co.,Ltd. All rights reserved.
//

#import "CYBaseVideoView.h"

@interface CYBaseVideoView ()<AVPlayerItemOutputPullDelegate>
{
    int             _playToEndCount;
    id              _avplayerTimeObserver;
    dispatch_queue_t _myVideoOutputQueue;
}
@property (nonatomic,readwrite,strong) AVPlayer         *player;
@property (nonatomic,readwrite,strong) NSString         *currentUrl;
@property (nonatomic,readwrite,strong) AVPlayerItemVideoOutput *videoOutput;

@end

@implementation CYBaseVideoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.player = [[AVPlayer alloc] init];
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;//待考量
        if (@available(iOS 10.0, *)) {
            self.player.automaticallyWaitsToMinimizeStalling = NO;
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        return nil;
    }
    return hitView;
}

#pragma mark - video output
- (void)enableVideoOutput:(BOOL)enable
{
    if (enable) {
        // Setup AVPlayerItemVideoOutput with the required pixelbuffer attributes.
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
        [[self videoOutput] setDelegate:self queue:_myVideoOutputQueue];
    }
    else {
        self.videoOutput = nil;
        _myVideoOutputQueue = 0;
    }
}

#pragma mark - 可重载
//AVPlayerItemOutputPullDelegate
- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
    NSLog(@"%@", @"outputMediaDataWillChange");
}

- (AVPlayerItem*)buildPlayerItemWithAsset:(AVAsset*)asset
{
    return [AVPlayerItem playerItemWithAsset:asset];
}

#pragma mark - method
- (void)setVideoPath:(NSString*)path
{
    NSURL *bipbopUrl = [NSURL fileURLWithPath:path];
    [self setVideoPathURL:bipbopUrl];
}

- (void)setVideoPathURL:(NSURL*)pathURL
{
    self.currentUrl = pathURL.path;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:pathURL options:nil];
    //这里处理视频
    AVPlayerItem *playerItem = [self buildPlayerItemWithAsset:asset];
    if (playerItem) {
        [self setVideoPlayerItem:playerItem];
    } else { //初始化失败
        if ([_delegate respondsToSelector:@selector(videoPlayerDidLoopToEnd:)]) {
            [_delegate videoPlayerDidLoopToEnd:self];
        }
    }
}

- (void)setVideoPlayerItem:(AVPlayerItem*)playerItem
{
    [self.player pause];
    
    [self removePlayerItemObservers:_player.currentItem];
    [self removeProgressObserver];
    [self removeVideoOutput];
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    [self addPlayerItemObservers:playerItem];
    [self addProgressObserver];
    [self addVideoOutput];
    
    _playToEndCount = 0;
    [_player play];
}

- (int)currentLoopIndex
{
    return _playToEndCount;
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler
{
    if (self.player.currentItem)
    {
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (completionHandler) {
                completionHandler(finished);
            }
        }];
    }
}

- (void)stepToPercentage:(CGFloat)percentage
{
    CMTime time = CMTimeMultiplyByFloat64(self.player.currentItem.duration, percentage);
    [self seekToTime:time completionHandler:nil];
}

- (void)stepToSecond:(CGFloat)second
{
    CMTime time = CMTimeMakeWithSeconds(second, self.player.currentTime.timescale);
    [self seekToTime:time completionHandler:nil];
}


- (void)makeRectForView:(UIView*)view videoSize:(CGSize)videoSize
{
    //把视频缩进容器里是啥样
    CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(videoSize, self.bounds);
    
    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFit:
        {
            if(CGRectGetHeight(insetRect) == INFINITY ||
               CGRectGetWidth(insetRect) == INFINITY ){
                view.frame = self.bounds;
                NSLog(@"%s video size AVMakeRectWithAspectRatioInsideRect with self.bounds   insertRect isInfinite",__func__);
            }else{
                view.frame = insetRect;
            }
        }
            break;
        case UIViewContentModeScaleAspectFill:
        {


            CGFloat w = self.bounds.size.width;
            CGFloat h = videoSize.height*w/videoSize.width;
            if(w == INFINITY || h == INFINITY ){
                view.frame = self.bounds;
            }else{
                view.frame = CGRectMake(0, (self.bounds.size.height-h)/2.0, w, h);
                
            }
//            if (ABS(insetRect.size.width-self.bounds.size.width)<0.0001) {//容器比视频窄，简单理解为：上下有空
//                //fill之后，高度一致
//                CGFloat h = self.bounds.size.height;
//                CGFloat w = videoSize.width*h/videoSize.height;
//                view.frame = CGRectMake((self.bounds.size.width-w)/2.0, 0, w, h);
//            }
//            else {//容器比视频宽，简单理解为：左右有空
//                //fill之后，宽度一致
//                CGFloat w = self.bounds.size.width;
//                CGFloat h = videoSize.height*w/videoSize.width;
//                view.frame = CGRectMake(0, (self.bounds.size.height-h)/2.0, w, h);
//            }
        }
            break;
        case UIViewContentModeScaleToFill:
            view.frame = self.bounds;
            break;
        default:
            break;
    }
}

#pragma mark - observer
- (void)addPlayerItemObservers:(AVPlayerItem *)playerItem
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemFailedToPlayToEndTime:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:playerItem];
    
    
}

- (void)removePlayerItemObservers:(AVPlayerItem *)playerItem
{
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
    }
}

- (void)playerItemFailedToPlayToEndTime:(NSNotification *)notification
{
    if (notification.object != self.player.currentItem)
    {
        return;
    }
    if ([_delegate respondsToSelector:@selector(videoPlayerFailedToPlay)]) {
        [_delegate videoPlayerFailedToPlay];
    }
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    if (notification.object != self.player.currentItem)
    {
        return;
    }
    
    ++_playToEndCount;
    if (self.loopCount>0)
    {
        if (_playToEndCount==self.loopCount) {
            if ([_delegate respondsToSelector:@selector(videoPlayerDidLoopToEnd:)]) {
                [_delegate videoPlayerDidLoopToEnd:self];
            }
            return;
        }
    }
    
    //    [self.player pause];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            //            [strongSelf.player play];
        }
    }];
}

#pragma mark - video output
- (void)removeVideoOutput
{
    if (self.videoOutput) {
        [[_player currentItem] removeOutput:self.videoOutput];
    }
}

- (void)addVideoOutput
{
    if (self.videoOutput) {
        [_player.currentItem addOutput:self.videoOutput];
        [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.03];//这个是不是算一下比较好？
    }
}

#pragma mark - progress

- (void)removeProgressObserver
{
    @try {
        if(_avplayerTimeObserver)
            [_player removeTimeObserver:_avplayerTimeObserver];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", @"removeObserver time exception");
    }
    @finally {
        
    }
}

- (void)addProgressObserver
{
    //    [self updateProgressWithCurrent:0 duration:self.duration];
    
    __weak typeof(self) weakSelf = self;
    _avplayerTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 20) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem* currentItem = weakSelf.player.currentItem;
        if(currentItem)
        {
            CGFloat current = CMTimeGetSeconds(currentItem.currentTime);
            CGFloat duration = CMTimeGetSeconds(currentItem.duration);
            if (current<=duration) {
                [weakSelf updateProgressWithCurrent:current duration:duration];
            }
        }
    }];
}

- (void)updateProgressWithCurrent:(CGFloat)current duration:(CGFloat)duration
{
    if (_delegate && duration>0) {
        
        if ([_delegate respondsToSelector:@selector(videoPlayer:current:duration:)]) {
            [_delegate videoPlayer:self current:current duration:duration];
        }
    }
}

- (void)stopCurrentPlayItem
{
    @try {
        if (_player.currentItem) {
            
            [self removePlayerItemObservers:_player.currentItem];
            [self removeProgressObserver];
            [self removeVideoOutput];
            
            if(_player.rate>0)[_player pause];
            [_player  replaceCurrentItemWithPlayerItem:nil];
            
            self.currentUrl = nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception when stopCurrentPlayItem: %@", exception);
    }
    @finally {
        
    }
}

- (void)clean
{
    [self stopCurrentPlayItem];
    if (self.videoOutput) {
        [self enableVideoOutput:NO];
    }
}
@end
