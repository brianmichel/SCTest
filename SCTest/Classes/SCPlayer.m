//
//  SCPlayer.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "SCPlayer.h"
#import "SCMedia.h"

@interface SCPlayer	() <AVAudioPlayerDelegate>
@property (strong) AVAudioPlayer *currentAudioPlayer;
@end

@implementation SCPlayer

@synthesize active = _active;

+ (instancetype)sharedPlayer {
  static SCPlayer *sharedPlayer = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedPlayer = [[SCPlayer alloc] init];
  });
  return sharedPlayer;
}

- (id)init {
  self = [super init];
  if (self) {
	//override point for more customization.
  }
  return self;
}

#pragma mark - Setters / Getters
- (void)setActive:(BOOL)active {
  _active = active;
  if (_active) {
	[self becomeFirstResponder];
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  } else {
	[self resignFirstResponder];
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  }
}

- (BOOL)active {
  return _active;
}

#pragma mark - Actions
- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (BOOL)playTrack:(SCTrack *)track {
  if (self.currentAudioPlayer) {
	[self.currentAudioPlayer stop];
	self.currentAudioPlayer = nil;
  }
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
  
  __weak SCPlayer *weakSelf = self;
  [SCRequest performMethod:SCRequestMethodGET onResource:track.streamURL usingParameters:nil withAccount:[SCSoundCloud account] sendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
	NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
	switch (resp.statusCode) {
	  case 200:
		[weakSelf beginPlaybackWithURL:track.streamURL];
		_currentTrack = track;
		break;
	  case 302: {
		NSString *movedLocation = [[resp allHeaderFields] valueForKey:@"Location"];
		[weakSelf beginPlaybackWithURL:[NSURL URLWithString:movedLocation]];
		_currentTrack = track;
	  } break;
	  default:
		break;
	}
  }];
  return YES;
}

- (BOOL)enqueueTrack:(SCTrack *)track {
  return NO;
}

- (BOOL)beginPlaybackWithURL:(NSURL *)url {
  NSError *error = nil;
  self.currentAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
  self.currentAudioPlayer.delegate = self;
  if (error) {
	[self.currentAudioPlayer stop];
	self.currentAudioPlayer = nil;
	self.active = NO;
	return NO;
  } else {
	self.active = YES;
	[self.currentAudioPlayer play];
	return YES;
  }
}

#pragma mark - AVAudioPlayer Delegate
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
  NSLog(@"FUCK: %@", error);
}

@end
