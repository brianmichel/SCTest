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
      self.textLabel.font = [Theme lightFontWithSize:18.0];
      self.textLabel.textColor = [UIColor whiteColor];
	  self.textLabel.shadowColor = [UIColor blackColor];
      self.textLabel.shadowOffset = CGSizeMake(0, 1);
      
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
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
  
  if (self.highlighted || self.selected) {
    CGContextSaveGState(ctx);
    {
      CGRect fillRect = CGRectMake(MarginSizes.small, 0, CGRectGetMaxX(self.bounds) - (MarginSizes.small * 3), self.frame.size.height);
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
