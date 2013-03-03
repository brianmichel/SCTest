//
//  WaveFormView.m
//  SCTest
//
//  Created by Brian Michel on 3/1/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "WaveFormView.h"
#import "FSNConnection.h"

@interface WaveFormView ()
@property (strong) FSNConnection *currentConnection;
@property (strong) NSDictionary *currentSampleDict;
@end

@implementation WaveFormView

@synthesize waveFormImage = _waveFormImage;
@synthesize waveFormURL = _waveFormURL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      self.backgroundColor = [UIColor clearColor];
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
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.12 alpha:0.11].CGColor);
    
    NSInteger numSamples = [samples count] / self.frame.size.width;
    NSInteger sampleAccumulatorStartPosition = 0;

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

#pragma mark - Actions


@end
