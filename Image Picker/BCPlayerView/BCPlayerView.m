//
//  BCPlayerView.m
//  TestApp
//
//  Created by Erfan on 9/7/19.
//  Copyright © 2019 Erfan. All rights reserved.
//

#import "BCPlayerView.h"

@interface BCPlayerView ()
{
    id playerObserver;
}

@end

@implementation BCPlayerView

- (void)dealloc
{
    NSLog(@"BCPlayerView deinit called.");
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        [self stopPlayer];
        [self removePlayerTimeObserver];
        [_playerItem removeObserver:self forKeyPath:@"status"];
    }
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    AVPlayer *player = [(AVPlayerLayer*)[self layer] player];
    if(!player)
    {
        player = [AVPlayer new];
        [self setPlayer:player];
    }
    return player;
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)removePlayer
{
    [(AVPlayerLayer*)[self layer] removeFromSuperlayer];
}

- (void)setPlayerItem:(AVPlayerItem *)item
{
    _playerItem = item;
    [_playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.player replaceCurrentItemWithPlayerItem:item];
}

- (void)setPlayerItem:(AVPlayerItem *)item withLoadingBlock:(BCPlayerViewItemLoaded)block
{
    _loadingBlock = block;
    [self setPlayerItem:item];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == _playerItem && [keyPath isEqualToString:@"status"]) {
        if (_playerItem.status == AVPlayerStatusReadyToPlay) {
            if(_loadingBlock)
                _loadingBlock(_playerItem.duration);
            if(self.delegate && [self.delegate respondsToSelector:@selector(playerViewPlayerIsReadyToPlay:)])
                [self.delegate playerViewPlayerIsReadyToPlay:self];
            if(self.delegate && [self.delegate respondsToSelector:@selector(playerView:playerItemDurationRetrieved:)])
                [self.delegate playerView:self playerItemDurationRetrieved:_playerItem.duration];
        }
    }
}

- (void)setVideoFillMode:(AVLayerVideoGravity)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (void)setLayerOpaity:(float)opacity
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.opacity = opacity;
}

- (void)useTapGestureToPlayPause
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
}

- (void)removeTapGestureToPlayPause
{
    [self removeGestureRecognizer:self.gestureRecognizers.firstObject];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if(self.player.rate == 0)
    {
        [self playPlayer];
    }
    else
    {
        [self stopPlayer];
    }
}

- (void)stopPlayer
{
    [self.player pause];
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerViewPlayerDidStopped:)])
        [self.delegate playerViewPlayerDidStopped:self];
}

- (void)playPlayer
{
    
    if (CMTIME_COMPARE_INLINE([self.player currentTime], >=, _playerItem.duration)) {
        [self seekToTimeInSeconds:0];
    }
    
    [self addPlayerTimeObserver];
    [self.player play];
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerViewPlayerDidPlay:)])
        [self.delegate playerViewPlayerDidPlay:self];
}

- (void)setPlayerVolume:(CGFloat)volume
{
    self.player.volume = volume;
}

- (void)setLoadingBlock:(BCPlayerViewItemLoaded)loadingBlock
{
    _loadingBlock = loadingBlock;
}

- (void)addPlayerTimeObserver
{
    // Removing the player time observer to avoid multiple call
    [self removePlayerTimeObserver];
    
    __weak BCPlayerView *weakSelf = self;
    double playerSliderDelay = .01f;
    playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(playerSliderDelay, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        if ((weakSelf.player.rate != 0) && (weakSelf.player.error == nil)) {
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerView:playerTimeChangedTo:)])
                [weakSelf.delegate playerView:self playerTimeChangedTo:time];
            
            if(weakSelf.shouldRepeatPlayer && CMTIME_COMPARE_INLINE(time, >= , weakSelf.player.currentItem.duration))
            {
                [weakSelf.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                    [weakSelf playPlayer];
                }];
            }
        }
    }];
}

- (void)removePlayerTimeObserver
{
    if (playerObserver) {
        [self.player removeTimeObserver:playerObserver];
        playerObserver = nil;
    }
}

- (void)seekToTimeInSeconds:(CGFloat)seconds
{
    [self stopPlayer];
    CMTime time = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//        [self.player play];
    }];
}

@end
