//
//  SCMedia.h
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SC_SHARING_TYPE) {
  SC_SHARING_TYPE_PUBLIC,
  SC_SHARING_TYPE_PRIVATE
};

typedef NS_ENUM(NSUInteger, SC_MEDIA_TYPE) {
  SC_MEDIA_TYPE_UNKNOWN,
  SC_MEDIA_TYPE_TRACK,
  SC_MEDIA_TYPE_PLAYLIST
};

typedef NS_ENUM(NSUInteger, SC_ARTWORK_SIZE) {
  SC_ARTWORK_SIZE_40 = 0,
  SC_ARTWORK_SIZE_50,
  SC_ARTWORK_SIZE_200,
  SC_ARTWORK_SIZE_300,
  SC_ARTWORK_SIZE_500,
  SC_ARTWORK_SIZE_ORIGINAL
};

struct SCReleaseInfo {
  NSUInteger release;
  NSUInteger day;
  NSUInteger month;
  NSUInteger year;
};

@class SCUser;
/* Base media object
 Will return either an SCTrack or an SCPlaylist
 depending on the initialization dictionary.
 */
@interface SCMedia : NSObject {
  @protected
  BOOL _mini;
  BOOL _streamable;
  BOOL _downloadable;
  
  SC_MEDIA_TYPE _mediaType;
}

/* Asserts whether or not the current representation is minified or not.
 
 Mini in terms of the Soundcloud API is whether or not the object has all
 of the fields filled out as it possibly could.
 */

@property (assign, readonly)  SC_MEDIA_TYPE mediaType;

@property (assign, readonly, getter = isMini) BOOL mini;
@property (assign, readonly, getter = isStreamable) BOOL streamable;
@property (assign, readonly, getter = isDownloadable) BOOL downloadable;

@property (assign, readonly) NSUInteger mediaID;
@property (assign, readonly) NSUInteger userID;
@property (assign, readonly) NSTimeInterval durationInMilliseconds;
@property (assign, readonly) SC_SHARING_TYPE sharing;

@property (strong, readonly) NSDate *createdAt;
@property (strong, readonly) NSURL *permalinkURL;
@property (strong, readonly) NSURL *purchaseURL;
@property (strong, readonly) NSURL *artworkURL;

@property (strong, readonly) SCUser *user;
@property (copy, readonly) NSString *trackDescription; //Note: This may contain HTML.
@property (copy, readonly) NSString *title;

//default initializer
+ (instancetype)mediaObjectForDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSURL *)artworkURLForSize:(SC_ARTWORK_SIZE)size;
@end

@interface SCTrack : SCMedia {
  @protected
  BOOL _commentable;
  BOOL _userFavorite;
}

@property (assign, readonly, getter = isCommentable) BOOL commentable;
@property (assign, readonly, getter = isUserFavorite) BOOL userFavorite;
@property (assign, readonly) NSUInteger beatsPerMinute;

@property (assign, readonly) NSUInteger commentCount;
@property (assign, readonly) NSUInteger downloadCount;
@property (assign, readonly) NSUInteger playbackCount;
@property (assign, readonly) NSUInteger favoritingsCount;

@property (strong, readonly) NSURL *waveformURL;
@property (strong, readonly) NSURL *streamURL;
@property (copy, readonly) NSString *keySignature;
@property (copy, readonly) NSString *isrc;
@end

@interface SCPlaylist : SCMedia

@property (assign, readonly) NSUInteger trackCount;

@property (strong, readonly) NSArray *tracks;
@property (copy, readonly) NSString *ean;
@end
