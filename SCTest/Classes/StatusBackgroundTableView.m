//
//  StatusBackgroundTableView.m
//  SCTest
//
//  Created by Brian Michel on 3/3/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "StatusBackgroundTableView.h"

@interface StatusBackgroundTableView ()
@property (strong) UIImageView *imageView;
@property (strong) UILabel *statusLabel;
@end

@implementation StatusBackgroundTableView

@dynamic displayImage;
@dynamic displayString;

- (void)commonInit {
  self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
  self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.statusLabel.backgroundColor = [UIColor clearColor];
  self.statusLabel.textAlignment = UITextAlignmentCenter;
  self.statusLabel.font = [UIFont fontWithName:@"GillSans" size:20.0];
  self.statusLabel.shadowColor = [UIColor whiteColor];
  self.statusLabel.shadowOffset = CGSizeMake(0, 1);
  self.statusLabel.textColor = [UIColor colorWithWhite:0.12 alpha:0.2];
  
  self.imageView.alpha = 0.0;
  self.statusLabel.alpha = 0.0;
  
  [self addSubview:self.imageView];
  [self addSubview:self.statusLabel];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
  self = [super initWithFrame:frame style:style];
  if (self) {
	[self commonInit];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if ([self.visibleCells count]) {
	[self showStatusView:NO animated:YES];
  } else {
	[self showStatusView:YES animated:YES];
  }
  
  CGFloat totalHeight = self.imageView.frame.size.height + self.statusLabel.frame.size.height;
  
  CGPoint beginLayoutPoint = CGPointMake(0, round(self.frame.size.height/2 - totalHeight/2));
  self.imageView.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - self.imageView.frame.size.width/2, beginLayoutPoint.y, self.imageView.frame.size.width, self.imageView.frame.size.height));
  self.statusLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 5, self.frame.size.width, self.statusLabel.frame.size.height);
}

#pragma mark - Actions
- (void)showStatusView:(BOOL)show animated:(BOOL)animated {
  CGFloat alpha = show ? 1.0 : 0.0;
  
  if (alpha == self.statusLabel.alpha) {return;}
  
  void(^animations)(void) = ^{
	self.statusLabel.alpha = show ? 1.0 : 0.0;
	self.imageView.alpha = show	 ? 1.0 : 0.0;
  };
  
  if (animated) {
	[UIView animateWithDuration:0.3 animations:animations];
  } else {
	animations();
  }
}

#pragma mark - Setters/Getters
- (void)setDisplayImage:(UIImage *)displayImage {
  self.imageView.image = displayImage;
  [self.imageView sizeToFit];
  [self setNeedsLayout];
}

- (void)setDisplayString:(NSString *)displayString {
  self.statusLabel.text = displayString;
  [self.statusLabel sizeToFit];
  [self setNeedsLayout];
}

- (NSString *)displayString {
  return self.statusLabel.text;
}

- (UIImage *)displayImage {
  return self.imageView.image;
}

@end
