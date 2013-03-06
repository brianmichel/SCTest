//
//  NSDate+Helpers.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "NSDate+Helpers.h"

static NSDateFormatter *createdAtFormatter;

@implementation NSDate (FormattedDate)
+ (NSDate *)dateFromSoundcloudString:(NSString *)soundcloudString {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
	createdAtFormatter = [[NSDateFormatter alloc] init];
	[createdAtFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss +zzzz"];
  });
  return [createdAtFormatter dateFromString:soundcloudString];
}
@end
