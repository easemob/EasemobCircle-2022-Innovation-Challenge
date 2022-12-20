//
//  PCPageView.m
//  PCPageDemo
//
//  Created by LYQ on 22/3/10.
//  Copyright (c) 2019年 com.duowan. All rights reserved.
//

#import "PCPageView.h"
#import <CoreText/CoreText.h>

@implementation PCPageView

- (void)setText:(NSAttributedString *)attributedText
{
    self.attributedText = attributedText;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFramesetterRef childFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:rect];
    CTFrameRef frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), bezierPath.CGPath, NULL);
    CTFrameDraw(frame, context);
    CFRelease(frame);
    CFRelease(childFramesetter);
}

@end
