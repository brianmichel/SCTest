//
//  SCUser.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "SCUser.h"

const struct kSCUserPropertyKeys {
  __unsafe_unretained NSString *userID;
  __unsafe_unretained NSString *trackCount;
  __unsafe_unretained NSString *followerCount;
  __unsafe_unretained NSString *followingsCount;
  __unsafe_unretained NSString *publicFavoritesCount;
  __unsafe_unretained NSString *username;
  __unsafe_unretained NSString *fullName;
  __unsafe_unretained NSString *country;
  __unsafe_unretained NSString *permalinkURL;
  __unsafe_unretained NSString *personalWebsiteURL;
  __unsafe_unretained NSString *avatarURL;
  __unsafe_unretained NSString *userDescription;
  __unsafe_unretained NSString *online;
} kSCUserPropertyKeys;

const struct kSCUserPropertyKeys UserPropertyKeys = {
  .userID = @"id",
  .trackCount = @"track_count",
  .followerCount = @"followers_count",
  .followingsCount = @"followings_count",
  .publicFavoritesCount = @"public_favorites_count",
  .username = @"username",
  .fullName = @"full_name",
  .country = @"country",
  .permalinkURL = @"permalink_url",
  .personalWebsiteURL = @"website",
  .avatarURL = @"avatar_url",
  .userDescription = @"description",
  .online = @"online"
};

@implementation SCUser

@synthesize online = _online;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  NSParameterAssert(dictionary != nil);
  self = [super init];
  if (self) {
	[self _processDictionary:dictionary];
  }
  return self;
}

#pragma mark - Helpers
- (void)_processDictionary:(NSDictionary *)dictionary {
  _username = SVK(dictionary, UserPropertyKeys.username);
  _userDescription = SVK(dictionary, UserPropertyKeys.userDescription);
  _fullName = SVK(dictionary, UserPropertyKeys.fullName);
  _country = SVK(dictionary, UserPropertyKeys.country);
}
@end
