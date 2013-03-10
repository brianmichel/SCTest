//
//  TouchPassingWindow.m
//  SCTest
//
//  Created by Brian Michel on 3/9/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "TouchPassingWindow.h"

@implementation TouchPassingWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  for (UIView *view in [self.rootViewController.view subviews]) {
    if ([view pointInside:[view convertPoint:point fromView:self] withEvent:event]) {
      return YES;
    }
  }
  return NO;
}

@end
