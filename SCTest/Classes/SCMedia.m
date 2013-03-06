//
//  SCMedia.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "SCMedia.h"

#pragma mark - SCMedia Begin
const struct kSCMediaBaseSharedPropertyKeys {
  __unsafe_unretained NSString *mediaID;
  __unsafe_unretained NSString *userID;
  __unsafe_unretained NSString *durationInMilliseconds;
  __unsafe_unretained NSString *createdAt;
  __unsafe_unretained NSString *description;
  __unsafe_unretained NSString *title;
  __unsafe_unretained NSString *permalinkURL;
  __unsafe_unretained NSString *purchaseURL;
  __unsafe_unretained NSString *streamable;
  __unsafe_unretained NSString *downloadable;
  __unsafe_unretained NSString *sharing;
} kSCMediaBaseSharedPropertyKeys;

const struct kSCMediaBaseSharedPropertyKeys BaseSharedKeys = {
  .mediaID = @"id",
  .userID = @"user_id",
  .durationInMilliseconds = @"duration",
  .createdAt = @"created_at",
  .description = @"description",
  .title = @"title",
  .permalinkURL = @"permalink_url",
  .streamable = @"streamable",
  .downloadable = @"downloadable",
  .sharing = @"sharing"
};

NSString * const kSCMediaKindKey = @"kind";
NSString * const kSCMediaKindTrack = @"track";
NSString * const kSCMediaKindPlaylist = @"playlist";

@interface SCMedia ()
- (void)_processDictionary:(NSDictionary *)dictionary;
@end

@implementation SCMedia

+ (instancetype)mediaObjectForDictionary:(NSDictionary *)dictionary {
  NSParameterAssert(dictionary != nil);
  Class dictClass = [[self class] classTypeForDictionary:dictionary];
  if (dictionary) {
	return [[dictClass alloc] initWithDictionary:dictionary];
  }
  return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark - Helpers
+ (Class)classTypeForDictionary:(NSDictionary *)dictionary {
  NSString *kindString = dictionary[kSCMediaKindKey];
  
  if ([kindString isEqualToString:kSCMediaKindTrack]) {
	return [SCTrack class];
  } else if ([kindString isEqualToString:kSCMediaKindPlaylist]) {
	return [SCPlaylist class];
  } else {
	return nil;
  }
}

- (void)_processDictionary:(NSDictionary *)dictionary {
  //stuff...  
  _title = dictionary[BaseSharedKeys.title];
  _trackDescription = dictionary[BaseSharedKeys.description];
  
  _permalinkURL = [self processPotentialURL:dictionary[BaseSharedKeys.permalinkURL]];
  _purchaseURL = [self processPotentialURL:dictionary[BaseSharedKeys.purchaseURL]];
  _mediaID = [dictionary[BaseSharedKeys.mediaID] integerValue];
  _userID = [dictionary[BaseSharedKeys.userID] integerValue];
  _downloadable = [dictionary[BaseSharedKeys.downloadable] boolValue];
  _streamable = [dictionary[BaseSharedKeys.streamable] boolValue];
  _durationInMilliseconds = [dictionary[BaseSharedKeys.durationInMilliseconds] doubleValue];
  
  NSString *sharingString = dictionary[BaseSharedKeys.sharing];
  _sharing = [sharingString isEqualToString:@"public"] ? SC_SHARING_TYPE_PUBLIC : SC_SHARING_TYPE_PRIVATE;
}

#pragma mark - Processors
- (NSURL *)processPotentialURL:(NSString *)string {
  NSURL *tempURL = nil;
  if (string && [string isKindOfClass:[NSString class]]) {
	tempURL = [NSURL URLWithString:string];
  }
  return tempURL;
}

@end

#pragma mark - SCTrack Begin
const struct kSCTrackPropertyKeys {
  __unsafe_unretained NSString *waveformURL;
  __unsafe_unretained NSString *artworkURL;
} kSCTrackPropertyKeys;

const struct kSCTrackPropertyKeys TrackPropertyKeys = {
  .waveformURL = @"waveform_url",
  .artworkURL = @"artwork_url"
};

@implementation SCTrack

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
	[self _processDictionary:dictionary];
  }
  return self;
}

- (void)_processDictionary:(NSDictionary *)dictionary {
  [super _processDictionary:dictionary];
  _artworkURL = [self processPotentialURL:dictionary[TrackPropertyKeys.artworkURL]];
  _waveformURL = [self processPotentialURL:dictionary[TrackPropertyKeys.waveformURL]];
}

@end

#pragma mark - SCPlaylist Begin
const struct kSCPlaylistPropertyKeys {
  __unsafe_unretained NSString *tracks;
} kSCPlaylistPropertyKeys;

const struct kSCPlaylistPropertyKeys PlaylistPropertyKeys = {
  .tracks = @"tracks"
};

@implementation SCPlaylist

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
	[self _processDictionary:dictionary];
  }
  return self;
}

- (void)_processDictionary:(NSDictionary *)dictionary {
  [super _processDictionary:dictionary];
  NSArray *tracks = dictionary[PlaylistPropertyKeys.tracks];
  NSMutableArray *tracksAccumulator = [NSMutableArray arrayWithCapacity:[tracks count]];
  for (NSDictionary *track in tracks) {
	SCMedia *media = [SCMedia mediaObjectForDictionary:track];
	if (media) {
	  [tracksAccumulator addObject:media];
	}
  }
  _tracks = [tracksAccumulator count] ? [NSArray arrayWithArray:tracksAccumulator] : nil;
}

- (BOOL)isMini {
  return ![self.tracks count];
}

@end
