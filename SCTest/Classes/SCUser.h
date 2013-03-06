//
//  SCUser.h
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCUser : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (assign, readonly, getter = isOnline) BOOL online;

@property (assign, readonly) NSUInteger userID;
@property (assign, readonly) NSUInteger trackCount;
@property (assign, readonly) NSUInteger followerCount;
@property (assign, readonly) NSUInteger followingsCount;
@property (assign, readonly) NSUInteger publicFavoritesCount;

@property (copy, readonly) NSString *username;
@property (copy, readonly) NSString *fullName;
@property (copy, readonly) NSString *country;
@property (copy, readonly) NSString *userDescription;

@property (strong, readonly) NSURL *permalinkURL;
@property (strong, readonly) NSURL *personalWebsiteURL;
@property (strong, readonly) NSURL *avatarURL;

@end