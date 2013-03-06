//
//  SCPlayer.h
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCTrack;

@interface SCPlayer : UIResponder

@property (assign) BOOL active; //this determines whether or not to generate remote events...
@property (strong, readonly) SCTrack *currentTrack;

+ (instancetype)sharedPlayer;

- (BOOL)enqueueTrack:(SCTrack *)track;
- (BOOL)playTrack:(SCTrack *)track;
@end
