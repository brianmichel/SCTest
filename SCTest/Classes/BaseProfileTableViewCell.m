//
//  BaseProfileTableViewCell.m
//  SCTest
//
//  Created by Brian Michel on 2/28/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "BaseProfileTableViewCell.h"

@implementation BaseProfileTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      self.textLabel.font = [UIFont fontWithName:@"GillSans-Light" size:18.0];
      self.textLabel.textColor = [UIColor whiteColor];
      self.textLabel.shadowOffset = CGSizeMake(0, 1);
      self.textLabel.shadowColor = [UIColor blackColor];
      
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(ctx);
  {
    CGContextSetLineWidth(ctx, 1);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.12 alpha:0.55].CGColor);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 5, CGRectGetMaxY(self.frame) - 1);
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(self.frame) - 10, CGRectGetMaxY(self.frame) - 1);
    
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    CGPathRelease(path);
  }
  CGContextRestoreGState(ctx);
  
  if (self.highlighted || self.selected) {
    CGContextSaveGState(ctx);
    {
      CGRect fillRect = CGRectMake(5, 0, CGRectGetMaxX(self.frame) - 15, self.frame.size.height);
      CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.05].CGColor);
      CGContextFillRect(ctx, fillRect);
    }
    CGContextRestoreGState(ctx);
  }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  [self setNeedsDisplay];
}
@end
