//
//  SCNavigationBar.m
//  SCTest
//
//  Created by Brian Michel on 3/11/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "SCNavigationBar.h"
#import "WaveFormView.h"
#import "MiniPlayingView.h"
#import "SCMedia.h"

@interface SCNavigationBar ()
@property (strong) SCTrack *track;
@property (strong) WaveFormView *waveformView;
@property (strong) MiniPlayingView *miniPlayingView;
@property (strong) UIButton *playPauseButton;
@end

@implementation SCNavigationBar

- (void)commonInit {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTrack:) name:kSCPlayerBeginPlayback object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPlaying:) name:kSCPlayerFinishedPlayback object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayhead:) name:kSCPlayerUpdatePlayhead object:nil];
  [[SCPlayer sharedPlayer] addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionInitial context:nil];
  
  self.waveformView = [[WaveFormView alloc] initWithFrame:CGRectZero];
  self.waveformView.waveFormColor = [Theme standardDarkColorWithAlpha:0.25];
  [self addSubview:self.waveformView];
  
  self.playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.playPauseButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
  [self.playPauseButton setImage:[UIImage imageNamed:@"play-icon"] forState:UIControlStateNormal];
  [self.playPauseButton sizeToFit];
  self.playPauseButton.alpha = 0.0;
  
  self.miniPlayingView = [[MiniPlayingView alloc] initWithFrame:CGRectZero];
  self.miniPlayingView.userInteractionEnabled = NO;
  [self addSubview:self.miniPlayingView];
  self.miniPlayingView.alpha = 0.0;
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTrackInfo:)];
  [self addGestureRecognizer:tap];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
	[self commonInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
	[self commonInit];
  }
  return self;
}

#pragma mark - Layout
- (void)layoutSubviews {
  [super layoutSubviews];
  self.waveformView.frame = self.bounds;
  self.miniPlayingView.frame = self.bounds;
  self.playPauseButton.frame = CGRectMake(self.playPauseButton.frame.origin.x, self.playPauseButton.frame.origin.y, self.frame.size.height, self.frame.size.height);
}

#pragma mark - Actions
- (void)newTrack:(NSNotification *)notification {
  self.track = (SCTrack *)notification.object;
  self.waveformView.waveFormURL = self.track.waveformURL;
  [UIView animateWithDuration:0.3 animations:^{
	self.playPauseButton.alpha = 1.0;
  } completion:^(BOOL finished) {
	[self flashInfo];
  }];
}

- (void)updatePlayhead:(NSNotification *)notification {
  NSNumber *progress = notification.userInfo[kSCPlayerUpdatePlayheadProgressKey];
  self.waveformView.progress = [progress doubleValue];
}

- (void)finishedPlaying:(NSNotification *)notification {
  [UIView animateWithDuration:0.3 animations:^{
	self.playPauseButton.alpha = 0.0;
  }];
}

- (void)playPause:(id)sender {
  if ([SCPlayer sharedPlayer].playing) {
    [[SCPlayer sharedPlayer] pause];
  } else {
    [[SCPlayer sharedPlayer] play];
  }
}

- (void)toggleTrackInfo:(UITapGestureRecognizer *)tapGesture {
  if (tapGesture.state == UIGestureRecognizerStateEnded || !tapGesture) {
	[self bringSubviewToFront:self.miniPlayingView];
	CGFloat alphaToGoTo = self.miniPlayingView.alpha == 1.0 ? 0.0 : 1.0;
	CGFloat otherComponentAlpha = self.miniPlayingView.alpha == 1.0 ? 1.0 : 0.0;
	[UIView animateWithDuration:0.3 animations:^{
	  self.miniPlayingView.alpha = alphaToGoTo;
	  self.topItem.titleView.alpha = otherComponentAlpha;
	}];
  }
}

- (void)flashInfo {
  if (self.miniPlayingView.alpha == 0.0) {
	[self toggleTrackInfo:nil];
  }
  double delayInSeconds = 2.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self toggleTrackInfo:nil];
  });
}

#pragma mark - Overrides
- (void)setItems:(NSArray *)items animated:(BOOL)animated {
  [super setItems:items animated:animated];
  self.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.playPauseButton];
}

#pragma mark - KVO Callback
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:@"playing"]) {
    if ([SCPlayer sharedPlayer].playing) {
      [self.playPauseButton setImage:[UIImage imageNamed:@"pause-icon"] forState:UIControlStateNormal];
    } else {
      [self.playPauseButton setImage:[UIImage imageNamed:@"play-icon"] forState:UIControlStateNormal];
    }
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[SCPlayer sharedPlayer] removeObserver:self forKeyPath:@"playing"];
}

@end
