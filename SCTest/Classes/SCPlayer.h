//
//  SCPlayer.h
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SC_PLAYER_STOP_REASON) {
  SC_PLAYER_STOP_REASON_USER = 0,
  SC_PLAYER_STOP_REASON_PLAY_THROUGH,
  SC_PLAYER_STOP_REASON_ERROR
};

OBJC_EXTERN NSString * const kSCPlayerBeginPlayback;
OBJC_EXTERN NSString * const kSCPlayerStopPlayback;
OBJC_EXTERN NSString * const kSCPlayerPausePlayback;
OBJC_EXTERN NSString * const kSCPlayerFinishedPlayback;
OBJC_EXTERN NSString * const kSCPlayerEnqueueTrack;
OBJC_EXTERN NSString * const kSCPlayerDequeueTrack;

OBJC_EXTERN NSString * const kSCPlayerClearQueue;
OBJC_EXTERN NSString * const kSCPlayerUpdatePlayhead;

OBJC_EXTERN NSString * const kSCPlayerUpdatePlayheadProgressKey;

@class SCTrack;

@interface SCPlayer : NSObject

@property (assign, readonly) BOOL playing; //this determines whether or not to generate remote events...
@property (assign) BOOL autoplay;
@property (assign) NSArray *allTracks;

@property (strong, readonly) SCTrack *currentTrack;


+ (instancetype)sharedPlayer;

- (void)enqueueTrack:(SCTrack *)track;
- (BOOL)dequeueTrack:(SCTrack *)track;
- (void)clearQueue;

- (void)playTrack:(SCTrack *)track;

- (void)play;
- (void)pause;
- (void)stop;
@end
