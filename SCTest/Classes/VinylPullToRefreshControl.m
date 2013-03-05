//
//  VinylPullToRefreshControl.m
//  SCTest
//
//  Created by Brian Michel on 3/3/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "VinylPullToRefreshControl.h"
#import "VinylActivityIndicatorView.h"

const CGFloat kPullToRefreshBeginningThreshold = 20.0;
const CGFloat kVinylPullToRefreshControlHeight = 50.0;

@interface VinylPullToRefreshControl ()
@property (strong) VinylActivityIndicatorView *vinylIndicator;
@property (strong) UIView *holeView;
@property (assign) BOOL animating;
@end

@implementation VinylPullToRefreshControl

@synthesize refreshing = _refreshing;

- (id)init {
  self = [super init];
  if (self) {
    self.vinylIndicator = [[VinylActivityIndicatorView alloc] initWithSpeed:VinylSpeed33];
	[self.vinylIndicator sizeToFit];
	
	self.holeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.vinylIndicator.frame.size.width + MarginSizes.small, 1)];
	self.holeView.backgroundColor = [UIColor blackColor];
	self.holeView.alpha = 0.0;
	self.holeView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.holeView.layer.shadowOffset = CGSizeMake(0, -1);
	self.holeView.layer.shadowRadius = 3.0;
	self.holeView.layer.shadowOpacity = 0.75;
	
	[self addSubview:self.vinylIndicator];
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
  self.vinylIndicator.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - self.vinylIndicator.frame.size.width/2, self.frame.size.height, self.vinylIndicator.frame.size.width, self.vinylIndicator.frame.size.height));
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
	
	self.frame = CGRectMake(0, -(kVinylPullToRefreshControlHeight), self.superview.frame.size.width, kVinylPullToRefreshControlHeight);
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
  _refreshing = YES;
  
  [self.vinylIndicator startAnimating];
  if ([self.superview isKindOfClass:[UIScrollView class]]) {
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	[UIView animateWithDuration:0.3 animations:^{
	  scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	  self.vinylIndicator.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - self.vinylIndicator.frame.size.width/2, self.vinylIndicator.frame.size.height/2, self.vinylIndicator.frame.size.width, self.vinylIndicator.frame.size.height));
	}];
  }
}

- (void)endRefreshing {
  if (!_refreshing) {
	return;
  }
  
  _refreshing = NO;
  
  [self.vinylIndicator stopAnimating];
  if ([self.superview isKindOfClass:[UIScrollView class]]) {
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	[UIView animateWithDuration:0.3 animations:^{
	  scrollView.contentInset = UIEdgeInsetsMake(-(kVinylPullToRefreshControlHeight), 0, 0, 0);
	} completion:^(BOOL finished) {
	  [self reset];
	}];
  }
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
	  self.vinylIndicator.frame = CGRectMake(self.vinylIndicator.frame.origin.x, self.frame.size.height - abs(offset + kPullToRefreshBeginningThreshold), self.vinylIndicator.frame.size.width, self.vinylIndicator.frame.size.height);
	}
	
	if (offset < -(kPullToRefreshBeginningThreshold * 2.0)) {
	  [self sendActionsForControlEvents:UIControlEventValueChanged];
	}
  }
}
@end
