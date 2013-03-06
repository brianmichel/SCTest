//
//  NSDictionary+Helpers.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "NSDictionary+Helpers.h"

@implementation NSDictionary (SafeValueForKey)
- (id)safeValueForKey:(NSString *)key {
  id object = self[key];
  if ([object isKindOfClass:[NSNull class]]) {
	return nil;
  }
  return object;
}
@end
