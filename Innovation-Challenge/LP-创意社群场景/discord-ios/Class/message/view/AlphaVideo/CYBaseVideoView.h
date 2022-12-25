//
//  CYBaseVideoView.h
//  SVGAPlayer
//
//  Created by lin jie on 2022/3/2.
//  Copyright © 2022 Voice Yuan Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CYBaseVideoView;
@protocol GLBaseVideoViewDelegate <NSObject>
@optional
- (void)videoPlayerFailedToPlay;
- (void)videoPlayerDidLoopToEnd:(CYBaseVideoView*)player;
- (void)videoPlayer:(CYBaseVideoView*)player current:(CGFloat)current duration:(CGFloat)duration;

@end

@interface CYBaseVideoView : UIView
@property (nonatomic, weak) id <GLBaseVideoViewDelegate> delegate;

@property (nonatomic,strong,readonly) AVPlayer *player;
@property (nonatomic,strong,readonly) AVPlayerItemVideoOutput *videoOutput;

@property (nonatomic, assign) NSInteger loopCount;// <=0 无限循环, >0算次数
@property (nonatomic, assign, readonly) int currentLoopIndex;//当前循环索引

- (void)setVideoPath:(NSString*)path;
- (void)setVideoPathURL:(NSURL*)pathURL;

- (void)stepToPercentage:(CGFloat)percentage;
- (void)stepToSecond:(CGFloat)second;

- (void)enableVideoOutput:(BOOL)enable;

- (void)stopCurrentPlayItem;
- (void)clean;

- (void)makeRectForView:(UIView*)view videoSize:(CGSize)videoSize;

//可以通过设contentMode来设置画面填充样式，内涵一致
// default is UIViewContentModeScaleToFill
//@property(nonatomic) UIViewContentMode contentMode;

@end

NS_ASSUME_NONNULL_END
