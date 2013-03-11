//
//  SCPlayer.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "SCPlayer.h"
#import "SCMedia.h"
#import "SCUser.h"

NSString * const kSCPlayerBeginPlayback = @"kSCPlayerBeginPlayback";
NSString * const kSCPlayerStopPlayback = @"kSCPlayerStopPlayback";
NSString * const kSCPlayerPausePlayback = @"kSCPlayerPausePlayback";
NSString * const kSCPlayerFinishedPlayback = @"kSCPlayerFinishedPlayback";
NSString * const kSCPlayerUpdatePlayhead = @"kSCPlayerUpdatePlayhead";
NSString * const kSCPlayerEnqueueTrack = @"kSCPlayerEnqueueTrack";
NSString * const kSCPlayerDequeueTrack = @"kSCPlayerDequeueTrack";
NSString * const kSCPlayerClearQueue= @"kSCPlayerClearQueue";

NSString * const kSCPlayerUpdatePlayheadProgressKey = @"progress";

@interface SCPlayer	()
@property (assign) dispatch_queue_t scPlayerQueue;
@property (strong) AVQueuePlayer *currentAudioPlayer;
@property (strong) id currentPlaybackTimeObserver;
@property (strong) NSMutableArray *trackQueue;
@property (strong) SCRequest *currentRequest;
@end

@implementation SCPlayer

@synthesize playing = _playing;
@dynamic allTracks;

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
    self.scPlayerQueue = dispatch_queue_create("SCPlayer Queue", DISPATCH_QUEUE_SERIAL);
    self.trackQueue = [NSMutableArray arrayWithCapacity:1];
  }
  return self;
}

#pragma mark - Actions

- (void)playTrack:(SCTrack *)track {
  [self tearDownPlayer];
  
  __weak SCPlayer *weakSelf = self;
  self.currentRequest = [SCRequest performMethod:SCRequestMethodHEAD onResource:track.streamURL usingParameters:nil withAccount:[SCSoundCloud account] sendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    if (resp.statusCode == 200) {
      dispatch_async(dispatch_get_main_queue(), ^{
        _currentTrack = track;
        [weakSelf beginPlaybackWithURL:resp.URL];
      });
    }
  }];
}

- (void)play {
  if (self.currentAudioPlayer) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCPlayerBeginPlayback object:self.currentTrack];
    [self.currentAudioPlayer play];
    
    [self willChangeValueForKey:@"playing"];
    _playing = YES;
    [self didChangeValueForKey:@"playing"];
  }
}

- (void)pause {
  if (self.currentAudioPlayer) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCPlayerPausePlayback object:self.currentTrack];
    [self.currentAudioPlayer pause];
    
    [self willChangeValueForKey:@"playing"];
    _playing = NO;
    [self didChangeValueForKey:@"playing"];
  }
}

- (void)stop {
  [self _stop:SC_PLAYER_STOP_REASON_USER withError:nil];
}

- (void)_stop:(SC_PLAYER_STOP_REASON)stopReason withError:(NSError *)error {
  [self tearDownPlayer];
  [self willChangeValueForKey:@"playing"];
  _playing = NO;
  [self didChangeValueForKey:@"playing"];
  
  switch (stopReason) {
    case SC_PLAYER_STOP_REASON_ERROR:
      [[NSNotificationCenter defaultCenter] postNotificationName:kSCPlayerStopPlayback object:error];
      break;
    case SC_PLAYER_STOP_REASON_PLAY_THROUGH:
      [[NSNotificationCenter defaultCenter] postNotificationName:kSCPlayerFinishedPlayback object:nil];
      break;
    case SC_PLAYER_STOP_REASON_USER:
      [[NSNotificationCenter defaultCenter] postNotificationName:kSCPlayerStopPlayback object:nil];
      break;
    default:
      break;
  }
}

- (NSArray *)allTracks {
  return [NSArray arrayWithArray:self.trackQueue];
}

- (void)enqueueTrack:(SCTrack *)track {
  [self.trackQueue addObject:track];
  [[NSNotificationCenter defaultCenter] postNotificationName:kSCPlayerEnqueueTrack object:track];
}

- (BOOL)dequeueTrack:(SCTrack *)track {
  if ([self.trackQueue containsObject:track]) {
    [self.trackQueue removeObject:track];
    return YES;
  }
  return NO;
}

- (void)clearQueue {
  [self.trackQueue removeAllObjects];
  [[NSNotificationCenter defaultCenter] postNotificationName:kSCPlayerClearQueue object:self];
}

- (SCTrack *)nextTrack {
  if ([self.trackQueue count]) {
    SCTrack *track = [self.trackQueue objectAtIndex:0];
    [self.trackQueue removeObjectAtIndex:0];
    return track;
  }
  return nil;
}

#pragma mark - Helpers
- (void)beginPlaybackWithURL:(NSURL *)url {
  self.currentAudioPlayer = [AVPlayer playerWithURL:url];
  [self willChangeValueForKey:@"playing"];
  _playing = YES;
  [self didChangeValueForKey:@"playing"];
  
  __weak SCPlayer *weakSelf = self;
  self.currentPlaybackTimeObserver = [self.currentAudioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:self.scPlayerQueue usingBlock:^(CMTime time) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:kSCPlayerUpdatePlayhead object:weakSelf.currentTrack userInfo:@{kSCPlayerUpdatePlayheadProgressKey: @((CMTimeGetSeconds(time) * 1000)/weakSelf.currentTrack.durationInMilliseconds)}];
	  
      if (!CMTimeCompare(time, weakSelf.currentAudioPlayer.currentItem.duration)) {
        SCTrack *track = [weakSelf nextTrack];
        if (track && weakSelf.autoplay) {
          [weakSelf playTrack:track];
        } else {
          [weakSelf _stop:SC_PLAYER_STOP_REASON_PLAY_THROUGH withError:nil];
        }
      }
    });
  }];
  
  if (self.currentTrack.artworkURL) {
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:self.currentTrack.artworkURL options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *infoDict = @{MPMediaItemPropertyTitle : _currentTrack.title,
                                   MPMediaItemPropertyLyrics : _currentTrack.trackDescription,
                                   MPMediaItemPropertyArtwork : [[MPMediaItemArtwork alloc] initWithImage:image],
                                   MPMediaItemPropertyBeatsPerMinute : @(_currentTrack.beatsPerMinute),
								   MPMediaItemPropertyArtist : _currentTrack.user.username
                                   };
        
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = infoDict;
      });
    }];
  }
  
  [self play];
}

- (void)tearDownPlayer {
  if (self.currentAudioPlayer) {
    [self.currentAudioPlayer pause];
    [self.currentAudioPlayer removeTimeObserver:self.currentPlaybackTimeObserver];
    self.currentPlaybackTimeObserver = nil;
    self.currentAudioPlayer = nil;
  }
  
  if (self.currentRequest) {
    [self.currentRequest cancel];
    self.currentRequest = nil;
  }
}

@end
