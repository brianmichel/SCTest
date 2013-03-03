//
//  VinylPullToRefreshControl.m
//  SCTest
//
//  Created by Brian Michel on 3/3/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "VinylPullToRefreshControl.h"

const CGFloat kPullToRefreshBeginningThreshold = 20.0;

@interface VinylPullToRefreshControl ()
@property (strong) UIImageView *vinylImage;
@property (strong) UIView *holeView;
@property (assign) BOOL animating;
@end

@implementation VinylPullToRefreshControl

@synthesize refreshing = _refreshing;

- (id)init {
  self = [super init];
  if (self) {
	self.vinylImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record-icon"]];
	[self.vinylImage sizeToFit];
	
	self.holeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.vinylImage.frame.size.width + 5, 1)];
	self.holeView.backgroundColor = [UIColor blackColor];
	self.holeView.alpha = 0.0;
	self.holeView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.holeView.layer.shadowOffset = CGSizeMake(0, -1);
	self.holeView.layer.shadowRadius = 3.0;
	self.holeView.layer.shadowOpacity = 0.75;
	
	[self addSubview:self.vinylImage];
	[self addSubview:self.holeView];
	
	self.clipsToBounds = YES;
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (self.animating || self.refreshing) {
	return;
  }
  self.vinylImage.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - self.vinylImage.frame.size.width/2, self.frame.size.height, self.vinylImage.frame.size.width, self.vinylImage.frame.size.height));
  self.holeView.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - self.holeView.frame.size.width/2, self.frame.size.height - self.holeView.frame.size.height, self.holeView.frame.size.width, self.holeView.frame.size.height));
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
  if ([self.superview isKindOfClass:[UIScrollView class]]) {
	[self.superview removeObserver:self forKeyPath:@"contentOffset"];
  }
}

- (void)didMoveToSuperview {
  if ([self.superview isKindOfClass:[UIScrollView class]]) {
	[self.superview addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
	
	self.frame = CGRectMake(0, -50, self.superview.frame.size.width, 50);
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self setNeedsLayout];
  }
}

#pragma mark - Setters/Getters
- (BOOL)isRefreshing {
  return _refreshing;
}

#pragma mark - Actions
- (void)reset {
  self.holeView.alpha = 0.0;
  self.animating = NO;
  _refreshing = NO;
  [self setNeedsLayout];
}

- (void)beginRefreshing {
  if (_refreshing) {
	return;
  }
  
  [self.vinylImage.layer addAnimation:[self rotationAnimation] forKey:nil];
  
  if ([self.superview isKindOfClass:[UIScrollView class]]) {
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	[UIView animateWithDuration:0.3 animations:^{
	  scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	  self.vinylImage.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - self.vinylImage.frame.size.width/2, self.vinylImage.frame.size.height/2, self.vinylImage.frame.size.width, self.vinylImage.frame.size.height));
	}];
  }
}

- (void)endRefreshing {
  if (!_refreshing) {
	return;
  }
  
  _refreshing = NO;
  
  [self.vinylImage.layer removeAllAnimations];
  
  if ([self.superview isKindOfClass:[UIScrollView class]]) {
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	[UIView animateWithDuration:0.3 animations:^{
	  scrollView.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0);
	} completion:^(BOOL finished) {
	  [self reset];
	}];
  }
}

- (CAAnimation *)rotationAnimation {
  CATransform3D transform = CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0);
  
  CABasicAnimation *animation;
  animation = [CABasicAnimation animationWithKeyPath:@"transform"];

  animation.fromValue = 0;
  animation.toValue = [NSValue valueWithCATransform3D:transform];
  animation.duration = 1.2;
  animation.cumulative = YES;
  animation.repeatCount = HUGE_VALF;
  return animation;
}

#pragma mark - KVO Stuff
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (object == self.superview && [keyPath isEqualToString:@"contentOffset"]) {
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	CGFloat offset = scrollView.contentOffset.y;
	
	if (_refreshing) {
	  return;
	}
	
	if (offset < -kPullToRefreshBeginningThreshold) {
	  CGFloat alpha = fabsf(offset + kPullToRefreshBeginningThreshold) / 100.0;
	  self.holeView.alpha = alpha;
	  self.vinylImage.frame = CGRectMake(self.vinylImage.frame.origin.x, self.frame.size.height - abs(offset + kPullToRefreshBeginningThreshold), self.vinylImage.frame.size.width, self.vinylImage.frame.size.height);
	}
	
	if (offset < -(kPullToRefreshBeginningThreshold * 2.0)) {
	  [self sendActionsForControlEvents:UIControlEventValueChanged];
	  _refreshing = YES;
	}
  }
}
@end
