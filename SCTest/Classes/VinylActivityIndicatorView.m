//
//  VinylActivityIndicatorView.m
//  SCTest
//
//  Created by Brian Michel on 3/4/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "VinylActivityIndicatorView.h"

const CGFloat kVinylSpeed45 = 1.0;
const CGFloat kVinylSpeed33 = 1.2;

const CGFloat kVinylImageHW = 50;

@interface VinylActivityIndicatorView ()
@property (strong) UIImageView *imageView;
@end

@implementation VinylActivityIndicatorView

@synthesize speed = _speed;
@synthesize hidesWhenStopped = _hidesWhenStopped;

- (void)commonInit {
  self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record-icon"]];
  [self.imageView sizeToFit];
  [self addSubview:self.imageView];
}

- (instancetype)initWithSpeed:(VinylSpeed)speed {
  self = [super initWithFrame:CGRectMake(0, 0, kVinylImageHW, kVinylImageHW)];
  if (self) {
    _speed = speed;
    [self commonInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.imageView.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - self.imageView.frame.size.width/2, self.frame.size.height/2 - self.imageView.frame.size.height/2, self.imageView.frame.size.width, self.imageView.frame.size.height));
}

#pragma mark - Actions
- (void)startAnimating {
  if (self.hidesWhenStopped && self.hidden) {
    self.hidden = NO;
  }
  [self.imageView.layer addAnimation:[self rotationAnimation] forKey:nil];
}

- (void)stopAnimating {
  if (self.hidesWhenStopped) {
    self.hidden = YES;
  }
  [self.imageView.layer removeAllAnimations];
}

- (CAAnimation *)rotationAnimation {
  CATransform3D transform = CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0);
  
  CABasicAnimation *animation;
  animation = [CABasicAnimation animationWithKeyPath:@"transform"];
  
  CGFloat animationSpeed = 0;
  switch (_speed) {
    case VinylSpeed33:
      animationSpeed = kVinylSpeed33;
      break;
    case VinylSpeed45:
      animationSpeed = kVinylSpeed45;
    default:
      animationSpeed = kVinylSpeed45;
      break;
  }
  
  animation.fromValue = [NSValue valueWithCATransform3D:transform];
  animation.toValue = 0;
  animation.duration = animationSpeed;
  animation.cumulative = YES;
  animation.repeatCount = HUGE_VALF;
  animation.fillMode = kCAFillModeForwards;
  return animation;
}

#pragma mark - Setters / Getters
- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
  _hidesWhenStopped = hidesWhenStopped;
  if (![self.imageView.layer.animationKeys count]) {
    self.hidden = _hidesWhenStopped;
  }
}

- (BOOL)hidesWhenStopped {
  return _hidesWhenStopped;
}

@end
