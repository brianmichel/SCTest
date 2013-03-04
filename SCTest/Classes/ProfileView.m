//
//  ProfileView.m
//  SCTest
//
//  Created by Brian Michel on 2/28/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "ProfileView.h"

const CGFloat kProfileViewAvatarHW = 100.0;

@interface ProfileView ()
@property (strong) UIImageView *avatarImageView;
@property (strong) UIImageView *avatarInsetImageView;
@property (strong) UILabel *nameLabel;
@end

@implementation ProfileView

@synthesize userInformationDictionary = _userInformationDictionary;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      self.backgroundColor = [UIColor clearColor];
      
      self.avatarInsetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar-inset"]];
      
      self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
      self.avatarImageView.layer.masksToBounds = YES;
      
      self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      self.nameLabel.textAlignment = UITextAlignmentCenter;
      self.nameLabel.font = [UIFont fontWithName:@"Futura-Medium" size:20.0];
      self.nameLabel.textColor = [UIColor whiteColor];
      self.nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.35];
      self.nameLabel.shadowOffset = CGSizeMake(0, 1);
      self.nameLabel.backgroundColor = [UIColor clearColor];
      
      [self addSubview:self.avatarImageView];
      [self addSubview:self.avatarInsetImageView];
      [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.avatarImageView.frame = CGRectIntegral(CGRectMake(self.frame.size.width/2 - kProfileViewAvatarHW/2, MarginSizes.small, kProfileViewAvatarHW, kProfileViewAvatarHW));
  self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.avatarImageView.frame) + MarginSizes.small, self.frame.size.width, self.nameLabel.frame.size.height);
  self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height/2;
  self.avatarInsetImageView.frame = self.avatarImageView.frame;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();

  CGContextSaveGState(ctx);
  {
    CGContextSetLineWidth(ctx, 4);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.12, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.12 alpha:0.55].CGColor);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, MarginSizes.small, CGRectGetMaxY(self.bounds));
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(self.bounds) - (MarginSizes.small * 2), CGRectGetMaxY(self.bounds));
    
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    CGPathRelease(path);
  }
  CGContextRestoreGState(ctx);
}

#pragma mark - Setters / Getters
- (void)setUserInformationDictionary:(NSDictionary *)userInformationDictionary {
  if ([_userInformationDictionary isEqualToDictionary:userInformationDictionary]) {
    return;
  }
  _userInformationDictionary = userInformationDictionary;
  
  self.nameLabel.text = _userInformationDictionary[@"username"];
  [self.nameLabel sizeToFit];
  NSURL *avatarURL = [NSURL URLWithString:_userInformationDictionary[@"avatar_url"]];
  if (avatarURL) {
    [self.avatarImageView setImageWithURL:avatarURL];
  }
}

- (NSDictionary *)userInformationDictionary {
  return _userInformationDictionary;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
