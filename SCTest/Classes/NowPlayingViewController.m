//
//  NowPlayingViewController.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "MiniPlayingView.h"
#import "SCMedia.h"

@interface NowPlayingViewController ()
@property (strong) UIImageView *imageView;
@property (strong) MiniPlayingView *miniPlayer;
@property (assign) BOOL opened;
@end

@implementation NowPlayingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartPlaying:) name:kSCPlayerBeginPlayback object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStopPlaying:) name:kSCPlayerStopPlayback object:nil];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.miniPlayer = [[MiniPlayingView alloc] initWithFrame:CGRectZero];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.miniPlayer addGestureRecognizer:pan];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor darkGrayColor];
  
  self.view.layer.shadowColor = [UIColor blackColor].CGColor;
  self.view.layer.shadowOffset = CGSizeMake(0, -1);
  self.view.layer.shadowOpacity = 0.3;
  self.view.layer.shadowRadius = 4.0;
  
  
  self.miniPlayer.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
  self.imageView.frame = CGRectMake(0, CGRectGetMaxY(self.miniPlayer.frame), self.view.frame.size.width, self.view.frame.size.width);
  
  [self.view addSubview:self.miniPlayer];
  [self.view addSubview:self.imageView];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)didStartPlaying:(NSNotification *)notification {
  NSLog(@"Started Playing: %@", notification.object);
  SCTrack *track = (SCTrack *)notification.object;
  if (track.artworkURL) {
    [self.imageView setImageWithURL:track.artworkURL];
  }
  [self peek];
}

- (void)didStopPlaying:(NSNotification *)notification {
  NSLog(@"Stopped Playing");
}

- (void)didPan:(UIPanGestureRecognizer *)panGesture {
  CGPoint location = [panGesture locationInView:self.view.superview];
  
  switch (panGesture.state) {
    case UIGestureRecognizerStateBegan:
    case UIGestureRecognizerStateChanged: {
      if (location.y >= self.view.superview.frame.size.height - 350) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, location.y, self.view.frame.size.width, self.view.frame.size.height);
      }
    } break;
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateFailed: {
      CGFloat originToCloseTo = location.y < self.view.superview.frame.size.height/2 ? self.view.superview.frame.size.height - 350 : self.view.superview.frame.size.height - 30;
      [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, originToCloseTo, self.view.frame.size.width, self.view.frame.size.height);
      } completion:^(BOOL finished) {
        self.opened = originToCloseTo == 200 ? YES : NO;
      }];
    } break;
    default:
      break;
  }
}

- (void)peek {
  if (!self.opened) {
    CGFloat originY = self.view.layer.position.y;
    NSNumber *value1 = @(originY - 10);
    NSNumber *value2 = @(originY + 3);
    NSNumber *value3 = @(originY - 5);
    NSNumber *value4 = @(originY);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.values = @[value1, value2, value3, value4];
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [self.view.layer addAnimation:animation forKey:@"bounce"];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
