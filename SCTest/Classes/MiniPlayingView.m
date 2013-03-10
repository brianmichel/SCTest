//
//  MiniPlayingView.m
//  SCTest
//
//  Created by Brian Michel on 3/9/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "MiniPlayingView.h"
#import "SCMedia.h"
#import "SCUser.h"

@interface MiniPlayingView ()
@property (strong) UIImageView *avatarImageView;
@property (strong) MarqueeLabel *artistLabel;
@property (strong) MarqueeLabel *titleLabel;
@property (strong) UIButton *playPauseButton;
@end


@implementation MiniPlayingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      [[SCPlayer sharedPlayer] addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionInitial context:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackBegin:) name:kSCPlayerBeginPlayback object:nil];
      
      self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
      
      CGFloat animationDelay = 20.0;
      NSString *originSeperator = @"     ";
      
      self.artistLabel = [[MarqueeLabel alloc] initWithFrame:CGRectZero duration:3.0 andFadeLength:10.0f];
      self.artistLabel.backgroundColor = [UIColor clearColor];
      self.titleLabel.textAlignment = UITextAlignmentCenter;
      self.artistLabel.font = [Theme boldFontWithSize:15.0];
      self.artistLabel.textColor = [Theme standardLightWhiteColorWithAlpha:1.0];
      self.artistLabel.numberOfLines = 1;
      self.artistLabel.marqueeType = MLContinuous;
      self.artistLabel.animationDelay = animationDelay;
      self.artistLabel.continuousMarqueeSeparator = originSeperator;
      
      self.titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectZero duration:3.0 andFadeLength:10.0f];
      self.titleLabel.backgroundColor = [UIColor clearColor];
      self.titleLabel.textAlignment = UITextAlignmentCenter;
      self.titleLabel.font = [Theme regularFontWithSize:14.0];
      self.titleLabel.textColor = [Theme standardLightWhiteColorWithAlpha:1.0];
      self.titleLabel.numberOfLines = 1;
      self.titleLabel.marqueeType = MLContinuous;
      self.titleLabel.animationDelay = animationDelay;
      self.titleLabel.continuousMarqueeSeparator = originSeperator;

      
      self.playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      [self.playPauseButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
      
      [self addSubview:self.avatarImageView];
      [self addSubview:self.artistLabel];
      [self addSubview:self.titleLabel];
      [self addSubview:self.playPauseButton];
    }
    return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.avatarImageView.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
  self.playPauseButton.frame = CGRectMake(CGRectGetMaxX(self.bounds) - self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
  self.artistLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + MarginSizes.small, 0,  self.frame.size.width - (self.frame.size.height * 2.0) - MarginSizes.small * 2.0, round(self.frame.size.height/2));
  self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + MarginSizes.small, CGRectGetMaxY(self.artistLabel.frame),  self.frame.size.width - (self.frame.size.height * 2.0) - MarginSizes.small * 2.0, round(self.frame.size.height/2));
}

#pragma mark - Actions
- (void)trackBegin:(NSNotification *)notification {
  SCTrack *track = (SCTrack *)notification.object;
  NSURL *urlToLoad = track.user.avatarURL ? track.user.avatarURL :  track.artworkURL;
  [self.avatarImageView setImageWithURL:urlToLoad];
  self.artistLabel.text = track.user.username;
  self.titleLabel.text = track.title;
  
  [self.artistLabel sizeToFit];
  [self.titleLabel sizeToFit];
  
  self.artistLabel.fadeLength = 10.0f;
  self.titleLabel.fadeLength = 10.0f;
}

- (void)playPause:(id)sender {
  if ([SCPlayer sharedPlayer].playing) {
    [[SCPlayer sharedPlayer] pause];
  } else {
    [[SCPlayer sharedPlayer] play];
  }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:@"playing"]) {
    NSLog(@"PLAYING: %@", [SCPlayer sharedPlayer].playing ? @"YES" : @"NO");
    if ([SCPlayer sharedPlayer].playing) {
      [self.playPauseButton setTitle:@"||" forState:UIControlStateNormal];
    } else {
      [self.playPauseButton setTitle:@"|>" forState:UIControlStateNormal];
    }
  }
  
}

- (void)dealloc {
  [[SCPlayer sharedPlayer] removeObserver:self forKeyPath:@"playing"];
}

@end
