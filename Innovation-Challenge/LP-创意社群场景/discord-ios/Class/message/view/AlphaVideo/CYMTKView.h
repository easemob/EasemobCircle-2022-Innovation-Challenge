//
//  CYMTKView.h
//  SVGAPlayer
//
//  Created by mac on 2022/4/29.
//  Copyright © 2022 Voice Yuan Co.,Ltd. All rights reserved.
//

#import <MetalKit/MetalKit.h>

@interface CYMTKView : MTKView

@property (nonatomic, strong) CIImage *currentImage;
- (void)clearRender;

@end

