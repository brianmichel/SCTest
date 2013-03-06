//
//  BaseTrackTableViewCell.m
//  SCTest
//
//  Created by Brian Michel on 3/1/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "BaseTrackTableViewCell.h"
#import "WaveFormView.h"
#import "SCActivity.h"
#import "SCMedia.h"
#import "SCUser.h"

#define kBaseTrackTitleFont [UIFont fontWithName:@"GillSans" size:12.0]
#define kBaseTrackDetailFont [UIFont fontWithName:@"GillSans" size:15.0]
#define kBaseTrackDateFont [UIFont fontWithName:@"GillSans-Light" size:12.0];

const CGFloat kTrackCellWaveformHeight = 60.0;
const CGFloat kTrackCellStandardHeight = 44.0;

@interface OrangeGradientView : UIView

@end

const CGFloat kBaseTrackTableViewCellImageHW = 30.0;

static SORelativeDateTransformer *relativeDateTransformer;

@interface BaseTrackTableViewCell ()
@property (strong) UILabel *dateLabel;
@property (strong) WaveFormView *waveFormView;
@end

@implementation BaseTrackTableViewCell

@synthesize trackActivity = _trackActivity;

+ (CGFloat)heightForTrackTableViewCellWithInformation:(SCActivity *)trackActivity containedToSize:(CGSize)size {
  CGFloat height = MarginSizes.small;

  CGSize constrainSize = CGSizeMake(320 - kBaseTrackTableViewCellImageHW - (MarginSizes.small * 2.0), CGFLOAT_MAX);
  
  height += [trackActivity.media.title sizeWithFont:kBaseTrackDetailFont constrainedToSize:constrainSize lineBreakMode:UILineBreakModeWordWrap].height;
  height += [trackActivity.media.user.username sizeWithFont:kBaseTrackTitleFont constrainedToSize:constrainSize lineBreakMode:UILineBreakModeWordWrap].height;
  
  height += (MarginSizes.small * 2.0) + (kTrackCellWaveformHeight / 2);
  
  return height >= kTrackCellStandardHeight ? height : kTrackCellStandardHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    self.clipsToBounds = YES;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      relativeDateTransformer = [[SORelativeDateTransformer alloc] init];
    });
    
    self.selectedBackgroundView = [[OrangeGradientView alloc] initWithFrame:self.bounds];
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 2.0;
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.layer.borderColor = [Theme standardDarkColorWithAlpha:0.35].CGColor;
    
    self.detailTextLabel.numberOfLines =  0;
    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    self.detailTextLabel.font = kBaseTrackDetailFont;
    self.textLabel.font = kBaseTrackTitleFont;
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.font = kBaseTrackDateFont;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = self.detailTextLabel.textColor;
    self.dateLabel.highlightedTextColor = self.detailTextLabel.highlightedTextColor;
    
    self.waveFormView = [[WaveFormView alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:self.waveFormView];
    [self.contentView sendSubviewToBack:self.waveFormView];
    [self.contentView addSubview:self.dateLabel];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat defaultInset = MarginSizes.small;
  
  self.dateLabel.frame = CGRectMake(self.contentView.frame.size.width - self.dateLabel.frame.size.width - defaultInset, defaultInset, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
  self.imageView.frame = CGRectMake(defaultInset, defaultInset, kBaseTrackTableViewCellImageHW, kBaseTrackTableViewCellImageHW);
  self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + defaultInset, defaultInset, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
  self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, CGRectGetMaxY(self.textLabel.frame), self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
  self.waveFormView.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - kTrackCellWaveformHeight, self.frame.size.width, kTrackCellWaveformHeight);
}

#pragma mark - Setters / Getters
- (void)setTrackActivity:(SCActivity *)trackActivity {
  if ([_trackActivity isEqual:trackActivity]) {return;}
  
  _trackActivity = trackActivity;
  
  self.detailTextLabel.text = _trackActivity.media.title;
  self.textLabel.text = _trackActivity.media.user.username;
  self.dateLabel.text = [relativeDateTransformer transformedValue:_trackActivity.createdAt];
  
  if (_trackActivity.media.artworkURL) {
	[self.imageView setImageWithURL:_trackActivity.media.artworkURL placeholderImage:[UIImage imageNamed:@"avatar-holder-bkg"]];
  }
  
  switch (_trackActivity.media.mediaType) {
	case SC_MEDIA_TYPE_TRACK: {
	  SCTrack *track = (SCTrack *)_trackActivity.media;
	  if (track.waveformURL) {
		self.waveFormView.waveFormURL = track.waveformURL;
	  }
	} break;
	default:
	  break;
  }
  
  
  [self.dateLabel sizeToFit];
  [self.detailTextLabel sizeToFit];
  [self.textLabel sizeToFit];
}

- (SCActivity *)trackActivity {
  return _trackActivity;
}

@end

@implementation OrangeGradientView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(ctx);
  {
    CGContextSetAlpha(ctx, 0.54);
    CGRect fillRect = self.bounds;
    CGContextSetFillColorWithColor(ctx, [Theme soundCloudOrangeWithAlpha:1.0].CGColor);
    CGContextFillRect(ctx, fillRect);
    CGContextClipToRect(ctx, fillRect);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat colors[4] = {1.0, 0.8, 0.0, 0.8};
    CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(CGRectGetMidX(self.bounds), 0), CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)), kCGGradientDrawsAfterEndLocation|kCGGradientDrawsBeforeStartLocation);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
  }
  CGContextRestoreGState(ctx);
}

@end
