//
//  SCActivity.h
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SC_ACTIVITY_TYPE) {
  SC_ACTIVITY_TYPE_UNKNOWN = -1,
  SC_ACTIVITY_TYPE_TRACK,
  SC_ACTIVITY_TYPE_TRACK_SHARING,
  SC_ACTIVITY_TYPE_FAVORITING,
  SC_ACTIVITY_TYPE_COMMENT,
  SC_ACTIVITY_TYPE_PLAYLIST
};

@class SCMedia;

@interface SCActivity : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (assign, readonly) SC_ACTIVITY_TYPE activityType;

@property (strong, readonly) SCMedia *media;
@property (strong, readonly) NSDate *createdAt;
@end
