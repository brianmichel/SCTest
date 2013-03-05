//
//  Theme.h
//  SCTest
//
//  Created by Brian Michel on 3/4/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN const struct MarginSizes {
  CGFloat small;
  CGFloat medium;
  CGFloat large;
} MarginSizes;

@interface Theme : NSObject

+ (instancetype)currentTheme;

+ (UIFont *)regularFontWithSize:(CGFloat)size;
+ (UIFont *)boldFontWithSize:(CGFloat)size;
+ (UIFont *)lightFontWithSize:(CGFloat)size;
+ (UIFont *)ornamentFontWithSize:(CGFloat)size;

+ (UIColor *)standardDarkColorWithAlpha:(CGFloat)alpha;
+ (UIColor *)standardLightWhiteColorWithAlpha:(CGFloat)alpha;
+ (UIColor *)standardRedColorWithAlpha:(CGFloat)alpha;
+ (UIColor *)soundCloudOrangeWithAlpha:(CGFloat)alpha;

@end
