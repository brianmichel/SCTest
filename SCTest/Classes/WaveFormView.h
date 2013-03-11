//
//  WaveFormView.h
//  SCTest
//
//  Created by Brian Michel on 3/1/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveFormView : UIView

@property (strong) UIImage *waveFormImage;
@property (strong) NSURL *waveFormURL;

@property (strong) UIColor *waveFormColor;

@property (assign) double progress;

@end
