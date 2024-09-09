//
//  BCPlayerView.h
//  TestApp
//
//  Created by Erfan on 9/7/19.
//  Copyright © 2019 Erfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AVPlayer;
@class BCPlayerView;

typedef void (^BCPlayerViewItemLoaded)(CMTime duration);

@protocol BCPlayerViewDelegate <NSObject>

@optional
- (void)playerView:(BCPlayerView *)playerView playerTimeChangedTo:(CMTime)time;
- (void)playerViewPlayerDidStopped:(BCPlayerView *)playerView;
- (void)playerViewPlayerDidPlay:(BCPlayerView *)playerView;
- (void)playerViewPlayerIsReadyToPlay:(BCPlayerView *)playerView;
- (void)playerView:(BCPlayerView *)playerView playerItemDurationRetrieved:(CMTime)duration;

@end

@interface BCPlayerView : UIView
@property (nonatomic, weak) id<BCPlayerViewDelegate> delegate;
@property (nonatomic, copy) BCPlayerViewItemLoaded loadingBlock;
@property (nonatomic, copy) AVPlayerItem *playerItem;
@property (nonatomic) BOOL shouldRepeatPlayer;

- (void)setPlayer:(AVPlayer*)player;
- (void)removePlayer;
- (void)setPlayerItem:(AVPlayerItem *)item;
- (void)setPlayerItem:(AVPlayerItem *)item withLoadingBlock:(BCPlayerViewItemLoaded)block;
- (void)setVideoFillMode:(AVLayerVideoGravity)fillMode;
- (void)setLayerOpaity:(float)opacity;
- (void)seekToTimeInSeconds:(CGFloat)seconds;

- (void)useTapGestureToPlayPause;
- (void)removeTapGestureToPlayPause;
- (void)stopPlayer;
- (void)playPlayer;
- (void)setPlayerVolume:(CGFloat)volume;

@end

NS_ASSUME_NONNULL_END
