//
//  CYMTKView.m
//  SVGAPlayer
//
//  Created by Mike on 2022/7/17.
//  Copyright © 2022 Voice Yuan Co.,Ltd. All rights reserved.
//

#import "CYMTKView.h"

@interface CYMTKView ()
{
    CGColorSpaceRef     _colorSpace;
}
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

@end

@implementation CYMTKView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.opaque = NO;
    self.layer.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.device = MTLCreateSystemDefaultDevice();
    self.framebufferOnly = NO;
    self.paused = NO;
    self.enableSetNeedsDisplay = NO;
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    self.commandQueue = [self.device newCommandQueue];
    
    if (@available(iOS 9.0, *)) {
        _colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    } else {
        _colorSpace = CGColorSpaceCreateDeviceRGB();
    }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        return nil;
    }
    return hitView;
}

#pragma mark - getter
- (CIContext *)context
{
    if (!_context) {
        _context = [CIContext contextWithMTLDevice:self.device options:@{kCIContextWorkingColorSpace : [NSNull null] }];
    }
    return _context;
}

#pragma mark - setter
- (void)setCurrentImage:(CIImage *)currentImage
{
    _currentImage = currentImage;
    [self draw];
}

#pragma mark - override
- (void)drawRect:(CGRect)rect
{
    if (!self.currentImage) {
        return;
    }
    id<MTLTexture> currentTexture = self.currentDrawable.texture;
    CGRect drawingBounds = CGRectMake(0, 0, self.drawableSize.width, self.drawableSize.height);
    id <MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    CGFloat scaleX = self.drawableSize.width / self.currentImage.extent.size.width;
    CGFloat scaleY = self.drawableSize.height / self.currentImage.extent.size.height;
    CIImage *outputImage = [self.currentImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    [self.context render:outputImage toMTLTexture:currentTexture commandBuffer:commandBuffer bounds:drawingBounds colorSpace:_colorSpace];
    [commandBuffer presentDrawable:self.currentDrawable];
    [commandBuffer commit];
}

//没用
- (void)clearRender
{
    self.clearColor = MTLClearColorMake(0, 0, 0, 0);
    
    id <MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    [[commandBuffer renderCommandEncoderWithDescriptor:self.currentRenderPassDescriptor] endEncoding];
    
    [commandBuffer presentDrawable:self.currentDrawable];
    
    [commandBuffer commit];
    [commandBuffer waitUntilScheduled];
}
//Preparing Your Metal App to Run in the Background
//https://developer.apple.com/documentation/metal/preparing_your_metal_app_to_run_in_the_background
@end
