//
//  Theme.m
//  SCTest
//
//  Created by Brian Michel on 3/4/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "Theme.h"

NSString * const kThemeRegularFontName = @"GillSans";
NSString * const kThemeBoldFontName = @"GillSans-Bold";
NSString * const kThemeLightFontName = @"GillSans-Light";
NSString * const kThemeOrnamentFontName = @"BodoniOrnamentsITCTT";

const CGFloat kThemeStandardDarkColorWhitePoint = 0.12;

const struct MarginSizes MarginSizes = {
  .small = 5,
  .medium = 7,
  .large = 11
};

@implementation Theme

+ (instancetype)currentTheme {
  static dispatch_once_t onceToken;
  static Theme *currentTheme = nil;
  dispatch_once(&onceToken, ^{
    currentTheme = [[Theme alloc] init];
  });
  return currentTheme;
}

+ (UIFont *)regularFontWithSize:(CGFloat)size {
  return [UIFont fontWithName:kThemeRegularFontName size:size];
}

+ (UIFont *)boldFontWithSize:(CGFloat)size {
  return [UIFont fontWithName:kThemeBoldFontName size:size];
}

+ (UIFont *)lightFontWithSize:(CGFloat)size {
  return [UIFont fontWithName:kThemeLightFontName size:size];
}

+ (UIFont *)ornamentFontWithSize:(CGFloat)size {
  return [UIFont fontWithName:kThemeOrnamentFontName size:size];
}

+ (UIColor *)standardDarkColorWithAlpha:(CGFloat)alpha {
  return [UIColor colorWithWhite:kThemeStandardDarkColorWhitePoint alpha:alpha];
}

+ (UIColor *)standardLightWhiteColorWithAlpha:(CGFloat)alpha {
 return [UIColor colorWithRed:229/256.0 green:229/256.0 blue:229/256.0 alpha:alpha];
}

- (id)init {
  self = [super init];
  if (self) {
	//custom initialization
  }
  return self;
}

@end
