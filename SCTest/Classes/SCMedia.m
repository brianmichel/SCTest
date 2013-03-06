//
//  SCMedia.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "SCMedia.h"
#import "SCUser.h"

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
  __unsafe_unretained NSString *user;
  __unsafe_unretained NSString *artworkURL;
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
  .sharing = @"sharing",
  .user = @"user",
  .artworkURL = @"artwork_url"
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
  _mediaID = [SVK(dictionary, BaseSharedKeys.mediaID) integerValue];
  _userID = [SVK(dictionary, BaseSharedKeys.userID) integerValue];
  _downloadable = [SVK(dictionary, BaseSharedKeys.downloadable) boolValue];
  _streamable = [SVK(dictionary ,BaseSharedKeys.streamable) boolValue];
  _durationInMilliseconds = [SVK(dictionary, BaseSharedKeys.durationInMilliseconds) doubleValue];
  _user = [[SCUser alloc] initWithDictionary:dictionary[BaseSharedKeys.user]];
  _artworkURL = [self processPotentialURL:dictionary[BaseSharedKeys.artworkURL]];
  _createdAt = [NSDate dateFromSoundcloudString:dictionary[BaseSharedKeys.createdAt]];
  
  NSString *sharingString = SVK(dictionary, BaseSharedKeys.sharing);
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

#pragma mark - Getters
- (BOOL)isMini {
  return _mini;
}

- (BOOL)isStreamable {
  return _streamable;
}

- (BOOL)isDownloadable {
  return _downloadable;
}

@end

#pragma mark - SCTrack Begin
const struct kSCTrackPropertyKeys {
  __unsafe_unretained NSString *waveformURL;
  __unsafe_unretained NSString *streamURL;
  __unsafe_unretained NSString *commentable;
  __unsafe_unretained NSString *beatsPerMinute;
  __unsafe_unretained NSString *keySignature;
  __unsafe_unretained NSString *isrc;
  __unsafe_unretained NSString *commentCount;
  __unsafe_unretained NSString *downloadCount;
  __unsafe_unretained NSString *playbackCount;
  __unsafe_unretained NSString *favoritingsCount;
  __unsafe_unretained NSString *userFavorite;
} kSCTrackPropertyKeys;

const struct kSCTrackPropertyKeys TrackPropertyKeys = {
  .waveformURL = @"waveform_url",
  .streamURL = @"stream_url",
  .commentable = @"commentable",
  .beatsPerMinute = @"bpm",
  .keySignature = @"key_signature",
  .isrc = @"isrc",
  .commentCount = @"comment_count",
  .downloadCount = @"download_count",
  .playbackCount = @"playback_count",
  .favoritingsCount = @"favoritings_count",
  .userFavorite = @"user_favorite"
};

@implementation SCTrack

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
	_mediaType = SC_MEDIA_TYPE_TRACK;
	[self _processDictionary:dictionary];
  }
  return self;
}

- (void)_processDictionary:(NSDictionary *)dictionary {
  [super _processDictionary:dictionary];
  _waveformURL = [self processPotentialURL:dictionary[TrackPropertyKeys.waveformURL]];
  _streamURL = [self processPotentialURL:dictionary[TrackPropertyKeys.streamURL]];
  _commentable = [SVK(dictionary, TrackPropertyKeys.commentable) boolValue];
  _userFavorite = [SVK(dictionary, TrackPropertyKeys.userFavorite) boolValue];
  _beatsPerMinute = [SVK(dictionary, TrackPropertyKeys.beatsPerMinute) integerValue];
  _keySignature = dictionary[TrackPropertyKeys.keySignature];
  _isrc = dictionary[TrackPropertyKeys.isrc];
  _commentCount = [SVK(dictionary, TrackPropertyKeys.commentCount) integerValue];
  _downloadCount = [SVK(dictionary, TrackPropertyKeys.downloadCount) integerValue];
  _playbackCount = [SVK(dictionary, TrackPropertyKeys.playbackCount) integerValue];
  _favoritingsCount = [SVK(dictionary, TrackPropertyKeys.favoritingsCount) integerValue];
}

#pragma mark - Getters

- (BOOL)isCommentable {
  return _commentable;
}

- (BOOL)isUserFavorite {
  return _userFavorite;
}

@end

#pragma mark - SCPlaylist Begin
const struct kSCPlaylistPropertyKeys {
  __unsafe_unretained NSString *trackCount;
  __unsafe_unretained NSString *tracks;
  __unsafe_unretained NSString *ean;
} kSCPlaylistPropertyKeys;

const struct kSCPlaylistPropertyKeys PlaylistPropertyKeys = {
  .trackCount = @"track_count",
  .tracks = @"tracks",
  .ean = @"ean"
};

@implementation SCPlaylist

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
	_mediaType = SC_MEDIA_TYPE_PLAYLIST;
	[self _processDictionary:dictionary];
  }
  return self;
}

- (void)_processDictionary:(NSDictionary *)dictionary {
  [super _processDictionary:dictionary];
  NSArray *tracks = dictionary[PlaylistPropertyKeys.tracks];
  _trackCount = [SVK(dictionary, PlaylistPropertyKeys.trackCount) integerValue];
  NSMutableArray *tracksAccumulator = [NSMutableArray arrayWithCapacity:[tracks count]];
  for (NSDictionary *track in tracks) {
	SCMedia *media = [SCMedia mediaObjectForDictionary:track];
	if (media) {
	  [tracksAccumulator addObject:media];
	}
  }
  _tracks = [tracksAccumulator count] ? [NSArray arrayWithArray:tracksAccumulator] : nil;
  _ean = SVK(dictionary, PlaylistPropertyKeys.ean);
}

- (BOOL)isMini {
  return ![self.tracks count];
}

@end

