//
//  NSDictionary+Helpers.h
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SVK(__DICT__, __KEY__) [__DICT__ safeValueForKey:__KEY__]

@interface NSDictionary (SafeValueForKey)
//just return nil instead of an NSNull, because NSNull is almost useless.
- (id)safeValueForKey:(NSString *)key;
@end
