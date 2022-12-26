//
//  LSAlphaMCIVideoView.m
//  SVGAPlayer
//
//  Created by wang yu on 2022/1/2.
//  Copyright © 2022 Voice Yuan Co.,Ltd. All rights reserved.
//

#import "CYAlphaMTCIVideoView.h"
#import "CYMTKView.h"

@interface CYAlphaMTCIVideoView ()
@property (nonatomic, strong) CIFilter *blendFilter;
@property (nonatomic, strong) CYMTKView *renderView;
@property CADisplayLink *displayLink;
@end

@implementation CYAlphaMTCIVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.renderView];
        [self setupDisplayLink];
        [self enableVideoOutput:YES];
    }
    return self;
}

- (void)setupDisplayLink
{
    // Setup CADisplayLink which will callback displayPixelBuffer: at every vsync.
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    self.displayLink.preferredFramesPerSecond = 20;
    [[self displayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [[self displayLink] setPaused:YES];
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        return nil;
    }
    return hitView;
}

#pragma mark - method
- (void)stopCurrentPlayItem
{
    //    self.renderView.currentImage = [CIImage imageWithColor:[CIColor clearColor]];
    [[self displayLink] setPaused:YES];
    //    [self.renderView clearRender];
    [super stopCurrentPlayItem];
    self.renderView.currentImage = nil;
    [self.renderView clearRender];
}

- (void)clean
{
    [super stopCurrentPlayItem];
    [[self displayLink] invalidate];
}

#pragma mark - 重载
- (AVPlayerItem*)buildPlayerItemWithAsset:(AVAsset*)asset
{
    //判断视频轨道，计算videoSize
    CGSize videoSize = CGSizeZero;
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count > 0) {
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        videoSize = CGSizeMake(clipVideoTrack.naturalSize.width/2.0, clipVideoTrack.naturalSize.height);
        
        [self makeRectForView:self.renderView videoSize:videoSize];
        
        return [AVPlayerItem playerItemWithAsset:asset];
    }
    else {
        return nil;
    }
}

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
    [[self displayLink] setPaused:NO];
}

#pragma mark - CADisplayLink Callback

- (void)displayLinkCallback:(CADisplayLink *)sender
{
    /*
     The callback gets called once every Vsync.
     Using the display link's timestamp and duration we can compute the next time the screen will be refreshed, and copy the pixel buffer for that time
     This pixel buffer can then be processed and later rendered on screen.
     */
    CMTime outputItemTime = kCMTimeInvalid;
    
    // Calculate the nextVsync time which is when the screen will be refreshed next.
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    
    outputItemTime = [[self videoOutput] itemTimeForHostTime:nextVSync];
//    NSLog(@"nextVSync:%f, outputItemTime:%f", nextVSync, CMTimeGetSeconds(outputItemTime));
    if ([[self videoOutput] hasNewPixelBufferForItemTime:outputItemTime]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        
        CIImage *originImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-(originImage.extent.size.width/2), 0.0);
        CIImage *alphaImage = [originImage imageByApplyingTransform:transform];
        
        //可以不设背景inputBackgroundImage
        [self.blendFilter setValue:originImage forKey:kCIInputImageKey];
        [self.blendFilter setValue:alphaImage forKey:kCIInputMaskImageKey];
        
        self.renderView.currentImage = _blendFilter.outputImage;
        
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
    }
}

#pragma mark - getter
- (CYMTKView *)renderView {
    if (!_renderView) {
        _renderView = [[CYMTKView alloc] initWithFrame:self.bounds];
        if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {//模拟器透明视频需要翻转
            [_renderView setTransform:CGAffineTransformMakeRotation(M_PI)];
        }
    }
    return _renderView;
}

- (CIFilter *)blendFilter
{
    if (!_blendFilter) {
        _blendFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
    }
    return _blendFilter;
}

@end
