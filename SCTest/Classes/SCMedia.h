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
@interface SCMedia : NSObject

//default initializer
+ (instancetype)mediaObjectForDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/* Asserts whether or not the current representation is minified or not.
 
 Mini in terms of the Soundcloud API is whether or not the object has all
 of the fields filled out as it possibly could.
 */
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
@property (strong, readonly) SCUser *user;
@property (copy, readonly) NSString *trackDescription; //Note: This may contain HTML.
@property (copy, readonly) NSString *title;
@end

@interface SCTrack : SCMedia

@property (strong, readonly) NSURL *waveformURL;
@property (strong, readonly) NSURL *artworkURL;
@end

@interface SCPlaylist : SCMedia

@property (strong, readonly) NSArray *tracks;

@end