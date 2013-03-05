//
//  LoadingAndTracksTableFooterView.m
//  SCTest
//
//  Created by Brian Michel on 3/4/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "LoadingAndTracksTableFooterView.h"
#import "VinylActivityIndicatorView.h"

static NSNumberFormatter *commaNumberFormatter;

@interface LoadingAndTracksTableFooterView ()
@property (strong) VinylActivityIndicatorView *activityIndicator;
@property (strong) UILabel *statusLabel;
@property (strong) UILabel *soundCountLabel;
@end

@implementation LoadingAndTracksTableFooterView

@synthesize soundCount = _soundCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
        commaNumberFormatter = [[NSNumberFormatter alloc] init];
        [commaNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [commaNumberFormatter setCurrencySymbol:@""];
        [commaNumberFormatter setMaximumFractionDigits:0];
      });
      
      self.activityIndicator = [[VinylActivityIndicatorView alloc] initWithSpeed:VinylSpeed33];
      self.activityIndicator.hidesWhenStopped = YES;
      self.statusLabel = [[UILabel alloc] initWithFrame:frame];
      self.statusLabel.backgroundColor = [UIColor clearColor];
      self.statusLabel.font = [Theme boldFontWithSize:14.0];
      self.statusLabel.textColor = [Theme standardRedColorWithAlpha:1.0];
      self.statusLabel.shadowColor = [UIColor whiteColor];
      self.statusLabel.shadowOffset = CGSizeMake(0, 1);
      self.statusLabel.textAlignment = UITextAlignmentCenter;
      self.statusLabel.alpha = 0.0;
      
      self.statusLabel.text = NSLocalizedString(@"Error loading, Tap to retry.", @"Download Failure Placeholder");
      
      self.soundCountLabel = [[UILabel alloc] initWithFrame:frame];
      self.soundCountLabel.backgroundColor = [UIColor clearColor];
      self.soundCountLabel.font = [Theme lightFontWithSize:20.0];
      self.soundCountLabel.textColor = [Theme standardDarkColorWithAlpha:0.35];
      self.soundCountLabel.shadowColor = [UIColor whiteColor];
      self.soundCountLabel.shadowOffset = CGSizeMake(0, 1);
      self.soundCountLabel.textAlignment = UITextAlignmentCenter;
      self.soundCountLabel.alpha = 0.0;
      
      [self addSubview:self.activityIndicator];
      [self addSubview:self.soundCountLabel];
      [self addSubview:self.statusLabel];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
      [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.statusLabel.frame = self.bounds;
  self.soundCountLabel.frame = self.bounds;
  
  self.activityIndicator.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - self.activityIndicator.frame.size.width/2, self.frame.size.height/2 - self.activityIndicator.frame.size.height/2, self.activityIndicator.frame.size.width, self.activityIndicator.frame.size.height));
}

#pragma mark - Actions
- (void)startLoading {
  if (self.activityIndicator.alpha == 1.0) {
    return;
  }
  
  [self.activityIndicator startAnimating];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.activityIndicator.alpha = 1.0;
    self.statusLabel.alpha = 0.0;
    self.soundCountLabel.alpha = 0.0;
  }];
}

- (void)stopLoadingWithError:(NSError *)error {
  self.error = error;
  //in the future we can offer specific errors.
  CGFloat statusAlpha = error ? 1.0 : 0.0;
  CGFloat soundCountLabel = error ? 0.0 : 1.0;
  
  [self.activityIndicator stopAnimating];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.activityIndicator.alpha = 0.0;
    self.statusLabel.alpha = statusAlpha;
    self.soundCountLabel.alpha = soundCountLabel;
  }];
}

- (void)tap:(UIGestureRecognizer *)tap {
  if (tap.state == UIGestureRecognizerStateEnded && self.retryBlock) {
    self.retryBlock();
  }
}

#pragma mark - Setters / Getters
- (void)setSoundCount:(NSUInteger)soundCount {
  _soundCount = soundCount;
  NSString *stringToDisplay = nil;
  if (soundCount > 0) {
    stringToDisplay = [NSString stringWithFormat:@"%@ %@", [commaNumberFormatter stringFromNumber:@(soundCount)], soundCount == 1 ? NSLocalizedString(@"Sound", nil) : NSLocalizedString(@"Sounds", nil)];
  } else {
    stringToDisplay = NSLocalizedString(@"No Sounds", nil);
  }
  self.soundCountLabel.text = stringToDisplay;
}

- (NSUInteger)soundCount {
  return _soundCount;
}
@end
