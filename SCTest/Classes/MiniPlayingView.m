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
@property (strong) UILabel  *playingLabel;
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
      self.playingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      self.playingLabel.backgroundColor = [UIColor clearColor];
      self.playingLabel.font = [Theme regularFontWithSize:18.0];
      self.playingLabel.textColor = [Theme standardLightWhiteColorWithAlpha:1.0];
      self.playingLabel.numberOfLines = 0;
      self.playingLabel.adjustsFontSizeToFitWidth = YES;
      self.playPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      [self.playPauseButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
      
      [self addSubview:self.avatarImageView];
      [self addSubview:self.playingLabel];
      [self addSubview:self.playPauseButton];
    }
    return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.avatarImageView.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
  self.playPauseButton.frame = CGRectMake(CGRectGetMaxX(self.bounds) - self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
  self.playingLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame), 0, self.frame.size.width - (self.frame.size.height * 2.0), self.frame.size.height);
}

#pragma mark - Actions
- (void)trackBegin:(NSNotification *)notification {
  SCTrack *track = (SCTrack *)notification.object;
  NSURL *urlToLoad = track.artworkURL ? track.artworkURL : track.user.avatarURL;
  [self.avatarImageView setImageWithURL:urlToLoad];
  self.playingLabel.text = [NSString stringWithFormat:@"%@ - %@", track.user.username, track.title];
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
