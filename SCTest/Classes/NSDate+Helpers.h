//
//  NSDate+Helpers.h
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FormattedDate)
+ (NSDate *)dateFromSoundcloudString:(NSString *)soundcloudString;
@end
