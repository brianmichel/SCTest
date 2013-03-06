//
//  SCActivity.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "SCActivity.h"
#import "SCMedia.h"

NSString * const kSCActivityTypeKey = @"type";
NSString * const kSCActivityOriginKey = @"origin";
NSString * const kSCActivityCreatedAtKey = @"created_at";

@implementation SCActivity

@synthesize activityType = _activityType;
@synthesize media = _media;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  NSParameterAssert(dictionary != nil);
  self = [super init];
  if (self) {
    [self _processDictionary:dictionary];
  }
  return self;
}

#pragma mark - Helper
- (void)_processDictionary:(NSDictionary *)dictionary {
  NSDictionary *origin = dictionary[kSCActivityOriginKey];
  NSString *typeString = dictionary[kSCActivityTypeKey];
  
  if ([typeString isEqualToString:@"track"]) {
    _activityType = SC_ACTIVITY_TYPE_TRACK;
  } else if ([typeString isEqualToString:@"track-sharing"]) {
    _activityType = SC_ACTIVITY_TYPE_TRACK_SHARING;
  } else if ([typeString isEqualToString:@"comment"]) {
    _activityType = SC_ACTIVITY_TYPE_COMMENT;
  } else if ([typeString isEqualToString:@"favoriting"]) {
    _activityType = SC_ACTIVITY_TYPE_FAVORITING;
  } else if ([typeString isEqualToString:@"playlist"]) {
    _activityType = SC_ACTIVITY_TYPE_PLAYLIST;
  } else {
    _activityType = SC_ACTIVITY_TYPE_UNKNOWN;
  }
  
  _media = [SCMedia mediaObjectForDictionary:origin];
}

@end
