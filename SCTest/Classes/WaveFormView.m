//
//  WaveFormView.m
//  SCTest
//
//  Created by Brian Michel on 3/1/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "WaveFormView.h"
#import <SDWebImageDownloader.h>

@implementation UIImage (Grayscale)

- (UIImage *) toGrayscale
{
  const int RED = 1;
  const int GREEN = 2;
  const int BLUE = 3;
  
  // Create image rectangle with current image width/height
  CGRect imageRect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
  
  int width = imageRect.size.width;
  int height = imageRect.size.height;
  
  // the pixels will be painted to this array
  uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
  
  // clear the pixels so any transparency is preserved
  memset(pixels, 0, width * height * sizeof(uint32_t));
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  // create a context with RGBA pixels
  CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                               kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
  
  // paint the bitmap to our context which will fill in the pixels array
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
  
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
      
      // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
      uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
      
      // set the pixels to gray
      rgbaPixel[RED] = gray;
      rgbaPixel[GREEN] = gray;
      rgbaPixel[BLUE] = gray;
    }
  }
  
  // create a new CGImageRef from our context with the modified pixels
  CGImageRef image = CGBitmapContextCreateImage(context);
  
  // we're done with the context, color space, and pixels
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  free(pixels);
  
  // make a new UIImage to return
  UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                               scale:self.scale
                                         orientation:UIImageOrientationUp];
  
  // we're done with image now too
  CGImageRelease(image);
  
  return resultUIImage;
}


@end

@interface WaveFormView ()
@property (strong) id<SDWebImageOperation>currentOperation;
@end

@implementation WaveFormView

@synthesize waveFormImage = _waveFormImage;
@synthesize waveFormURL = _waveFormURL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGImageRef image = NULL;
  
  CGContextSaveGState(ctx);
  {
    CGContextSetFillColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextFillRect(ctx, self.bounds);
    CGContextDrawImage(ctx, self.bounds, self.waveFormImage.CGImage);
    image = CGBitmapContextCreateImage(ctx);
  }
  
  CGContextSaveGState(ctx);
  {
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextClipToMask(ctx, self.bounds, image);
    CGContextFillRect(ctx, self.bounds);
    [self.waveFormImage drawInRect:self.bounds];
  }
  CGContextRestoreGState(ctx);
}

#pragma mark - Setters / Getters
- (void)setWaveFormURL:(NSURL *)waveFormURL {
  
  //don't look here, I don't want to use the image :)
  NSString *lastPath = [waveFormURL lastPathComponent];
  waveFormURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://wis.sndcdn.com/%@", lastPath]];
  
  if ([waveFormURL isEqual:_waveFormURL]) {return;}
  
  _waveFormURL = waveFormURL;
  
  if (self.currentOperation) {
    [self.currentOperation cancel];
    self.currentOperation = nil;
  }
  
  __weak  WaveFormView *weakSelf = self;
  self.currentOperation = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:waveFormURL options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
    if (!error) {
      //assure we're on the main queue for UI stuff
      weakSelf.waveFormImage = [image toGrayscale];
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setNeedsDisplay];
        //[self applyLayerMaskFromImage:image];
      });
    }
  }];
}

- (NSURL *)waveFormURL {
  return _waveFormURL;
}

- (void)setWaveFormImage:(UIImage *)waveFormImage {
  if ([waveFormImage isEqual:_waveFormImage]) {return;}
  
  _waveFormImage = waveFormImage;
  _waveFormURL = nil;
  [self setNeedsDisplay];
  //[self applyLayerMaskFromImage:waveFormImage];
}

- (UIImage *)waveFormImage {
  return _waveFormImage;
}

#pragma mark - Actions
- (void)applyLayerMaskFromImage:(UIImage *)maskImage {
  UIGraphicsBeginImageContext(CGSizeMake(self.bounds.size.width, self.bounds.size.height/2));
  
  UIImage * image = NULL;
  
  CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
  CGContextFillRect(UIGraphicsGetCurrentContext(), self.bounds);
  CGContextDrawImage(UIGraphicsGetCurrentContext(), self.bounds, maskImage.CGImage);
  image = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();
  
  CALayer *maskLayer = [CALayer layer];
  maskLayer.contents = (id)image.CGImage;
  maskLayer.frame = self.frame;
  
  self.layer.mask = maskLayer;
  self.waveFormImage = maskImage;
  self.backgroundColor = [UIColor redColor];
}

@end
