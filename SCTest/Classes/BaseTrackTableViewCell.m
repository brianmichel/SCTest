//
//  BaseTrackTableViewCell.m
//  SCTest
//
//  Created by Brian Michel on 3/1/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "BaseTrackTableViewCell.h"
#import "WaveFormView.h"

#define kBaseTrackTitleFont [UIFont fontWithName:@"GillSans" size:12.0]
#define kBaseTrackDetailFont [UIFont fontWithName:@"GillSans" size:15.0]
#define kBaseTrackDateFont [UIFont fontWithName:@"GillSans-Light" size:12.0];

const CGFloat kBaseTrackTableViewCellImageHW = 30.0;

static NSDateFormatter *trackTableDateFormatter;
static SORelativeDateTransformer *relativeDateTransformer;

@interface BaseTrackTableViewCell ()
@property (strong) UILabel *dateLabel;
@property (strong) WaveFormView *waveFormView;
@end

@implementation BaseTrackTableViewCell

@synthesize trackInformationDictionary = _trackInformationDictionary;

+ (CGFloat)heightForTrackTableViewCellWithInformation:(NSDictionary *)trackInformation containedToSize:(CGSize)size {
  CGFloat height = 5;
  NSString * title = [trackInformation valueForKeyPath:@"origin.title"];
  NSString * user = [trackInformation valueForKeyPath:@"origin.user.username"];
  
  
  CGSize constrainSize = CGSizeMake(320 - kBaseTrackTableViewCellImageHW - 10, CGFLOAT_MAX);
  
  height += [title sizeWithFont:kBaseTrackDetailFont constrainedToSize:constrainSize lineBreakMode:UILineBreakModeWordWrap].height;
  height += [user sizeWithFont:kBaseTrackTitleFont constrainedToSize:constrainSize lineBreakMode:UILineBreakModeWordWrap].height;
  
  height += 10;
  
  return height >= 44 ? height : 44;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    self.clipsToBounds = YES;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      trackTableDateFormatter = [[NSDateFormatter alloc] init];
      [trackTableDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss +zzzz"];
      relativeDateTransformer = [[SORelativeDateTransformer alloc] init];
    });
    
    
    self.imageView.layer.cornerRadius = 2.0;
    self.imageView.layer.borderColor = [UIColor colorWithWhite:0.12 alpha:0.35].CGColor;
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.layer.masksToBounds = YES;
    
    self.detailTextLabel.numberOfLines =  0;
    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    self.detailTextLabel.font = kBaseTrackDetailFont;
    self.textLabel.font = kBaseTrackTitleFont;
    
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
  
  self.dateLabel.frame = CGRectMake(self.contentView.frame.size.width - self.dateLabel.frame.size.width - 5, 5, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
  self.imageView.frame = CGRectMake(5, 5, kBaseTrackTableViewCellImageHW, kBaseTrackTableViewCellImageHW);
  self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + 5, 5, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
  self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, CGRectGetMaxY(self.textLabel.frame), self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
  self.waveFormView.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(ctx);
  {
    CGContextSetLineWidth(ctx, 1);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.12, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.12 alpha:0.55].CGColor);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 10, CGRectGetMaxY(self.bounds));
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(self.bounds) - 10, CGRectGetMaxY(self.bounds));
    
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    CGPathRelease(path);
  }
  CGContextRestoreGState(ctx);
  
  if (self.highlighted || self.selected) {
    CGContextSaveGState(ctx);
    {
      CGRect fillRect = CGRectMake(10, 0, CGRectGetMaxX(self.bounds) - 10, self.frame.size.height);
      CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.05].CGColor);
      CGContextFillRect(ctx, fillRect);
    }
    CGContextRestoreGState(ctx);
  }
}

#pragma mark - Setters / Getters
- (void)setTrackInformationDictionary:(NSDictionary *)trackInformationDictionary {
  if ([_trackInformationDictionary isEqualToDictionary:trackInformationDictionary]) {return;}
  
  _trackInformationDictionary = trackInformationDictionary;
  
  self.detailTextLabel.text = [_trackInformationDictionary valueForKeyPath:@"origin.title"];
  self.textLabel.text = [_trackInformationDictionary valueForKeyPath:@"origin.user.username"];
  NSDate *created_date = [trackTableDateFormatter dateFromString:_trackInformationDictionary[@"created_at"]];
  self.dateLabel.text = [relativeDateTransformer transformedValue:created_date];
  
  NSString *artworkURL = [_trackInformationDictionary valueForKeyPath:@"origin.artwork_url"] ? [_trackInformationDictionary valueForKeyPath:@"origin.artwork_url"] : [_trackInformationDictionary valueForKeyPath:@"origin.user.avatar_url"];
  
  if (artworkURL && ![artworkURL isKindOfClass:[NSNull class]]) {
    [self.imageView setImageWithURL:[NSURL URLWithString:artworkURL]];
  }
  
  NSString *waveFormURL = [_trackInformationDictionary valueForKeyPath:@"origin.waveform_url"];
  
  if (waveFormURL) {
    self.waveFormView.waveFormURL = [NSURL URLWithString:waveFormURL];
  }
  
  [self.dateLabel sizeToFit];
  [self.detailTextLabel sizeToFit];
  [self.textLabel sizeToFit];
}

- (NSDictionary *)trackInformationDictionary {
  return _trackInformationDictionary;
}

- (void)prepareForReuse {
  [self.imageView cancelCurrentImageLoad];
}

@end
