//
//  VinylActivityIndicatorView.h
//  SCTest
//
//  Created by Brian Michel on 3/4/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum VinylSpeed {
  VinylSpeed45 = 0,
  VinylSpeed33
} VinylSpeed;

@interface VinylActivityIndicatorView : UIView

@property (assign) BOOL hidesWhenStopped;
@property (assign, readonly) VinylSpeed speed;

- (instancetype)initWithSpeed:(VinylSpeed)speed;
- (void)startAnimating;
- (void)stopAnimating;
@end
