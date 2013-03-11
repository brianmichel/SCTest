//
//  WaveFormView.m
//  SCTest
//
//  Created by Brian Michel on 3/1/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "WaveFormView.h"
#import "FSNConnection.h"

#define kWaveFormViewDefaultWaveFormColor [Theme standardDarkColorWithAlpha:0.11]

@interface WaveFormView ()
@property (strong) FSNConnection *currentConnection;
@property (strong) NSDictionary *currentSampleDict;
@end

@implementation WaveFormView

@synthesize waveFormImage = _waveFormImage;
@synthesize waveFormURL = _waveFormURL;
@synthesize waveFormColor = _waveFormColor;
@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      self.backgroundColor = [UIColor clearColor];
	  self.clipsToBounds = YES;
	  _waveFormColor = kWaveFormViewDefaultWaveFormColor;
	  _progress = 0.0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  NSArray *samples = self.currentSampleDict[@"samples"];
  NSNumber *sampleHeight = self.currentSampleDict[@"height"];
  
  if (![samples count]) {
    return;
  }
  
  CGContextSaveGState(ctx);
  {
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, self.waveFormColor.CGColor);
    
    NSInteger numSamples = [samples count] / self.frame.size.width;
    NSInteger sampleAccumulatorStartPosition = 0;
	//resample data to fit our width
    for (NSInteger i = 0; i < self.frame.size.width; i++) {
      CGFloat lineHeightAccumulator = 0;
      for (NSInteger j = sampleAccumulatorStartPosition; j <  (sampleAccumulatorStartPosition + numSamples); j++) {
        NSNumber *sample = samples[j];
        CGFloat lineHeight = ([sample floatValue] / [sampleHeight floatValue]) * self.frame.size.height;
        lineHeightAccumulator += lineHeight;
      }
      
      CGFloat lineHeight = lineHeightAccumulator / numSamples;
      
      CGMutablePathRef path = CGPathCreateMutable();
      CGPathMoveToPoint(path, NULL, i, CGRectGetMaxY(self.frame));
      CGPathAddLineToPoint(path, NULL, i, CGRectGetMaxY(self.frame) - lineHeight);
      CGContextAddPath(ctx, path);
      CGPathRelease(path);
      
      sampleAccumulatorStartPosition += numSamples;
    }
    CGContextStrokePath(ctx);
  }
  CGContextRestoreGState(ctx);
  
  if (self.progress >= 0) {
	CGContextSaveGState(ctx);
	{
	  CGContextSetBlendMode(ctx, kCGBlendModeSourceIn);
	  CGFloat width = self.frame.size.width * self.progress;
	  CGRect progressRect = CGRectMake(0, 0, width, self.frame.size.height);
	  CGContextSetFillColorWithColor(ctx, [Theme soundCloudOrangeWithAlpha:1.0].CGColor);
	  CGContextFillRect(ctx, progressRect);
	}
	CGContextRestoreGState(ctx);
  }
}

#pragma mark - Setters / Getters
- (void)setWaveFormURL:(NSURL *)waveFormURL {
  
  //don't look here, I don't want to use the image :)
  NSString *lastPath = [waveFormURL lastPathComponent];
  NSArray *lastPathComponents = [lastPath componentsSeparatedByString:@"_"];
  if ([lastPathComponents count] == 2) {
    lastPath = [NSString stringWithFormat:@"%@_m.png", lastPathComponents[0]];
  }
  waveFormURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://wis.sndcdn.com/%@", lastPath]];
  
  if ([waveFormURL isEqual:_waveFormURL]) {return;}
  
  _waveFormURL = waveFormURL;
  
  if (self.currentConnection) {
    [self.currentConnection cancel];
    self.currentConnection = nil;
  }
  
  __weak  WaveFormView *weakSelf = self;
  self.currentConnection = [FSNConnection withUrl:_waveFormURL method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:nil completionBlock:^(FSNConnection *connection) {
    NSError *error = nil;
    NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:connection.responseData options:0 error:&error];
    if (error) {
      //handle something
      return;
    }
    weakSelf.currentSampleDict = returnDict;
    [weakSelf setNeedsDisplay];
  } progressBlock:nil];
  [self.currentConnection start];
}

- (NSURL *)waveFormURL {
  return _waveFormURL;
}

- (void)setWaveFormImage:(UIImage *)waveFormImage {
  if ([waveFormImage isEqual:_waveFormImage]) {return;}
  
  _waveFormImage = waveFormImage;
  _waveFormURL = nil;
  [self setNeedsDisplay];
}

- (UIImage *)waveFormImage {
  return _waveFormImage;
}

- (void)setWaveFormColor:(UIColor *)waveFormColor {
  _waveFormColor = waveFormColor ? waveFormColor : kWaveFormViewDefaultWaveFormColor;
  [self setNeedsDisplay];
}

- (UIColor *)waveFormColor {
  return _waveFormColor;
}

- (void)setProgress:(double)progress {
  _progress = progress > 1.0 ? 1.0 : progress;
  [self setNeedsDisplay];
}

- (double)progress {
  return _progress;
}

@end
