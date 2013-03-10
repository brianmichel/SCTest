//
//  NowPlayingViewController.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "MiniPlayingView.h"

@interface NowPlayingViewController ()
@property (strong) UIScrollView *scrollContainer;
@property (strong) MiniPlayingView *miniPlayer;
@end

@implementation NowPlayingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartPlaying:) name:kSCPlayerBeginPlayback object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStopPlaying:) name:kSCPlayerStopPlayback object:nil];
    
    self.scrollContainer = [[UIScrollView alloc] initWithFrame:CGRectZero];
    
    self.miniPlayer = [[MiniPlayingView alloc] initWithFrame:CGRectZero];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:pan];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor darkGrayColor];
  
  self.view.layer.shadowColor = [UIColor blackColor].CGColor;
  self.view.layer.shadowOffset = CGSizeMake(0, -1);
  self.view.layer.shadowOpacity = 1.0;
  self.view.layer.shadowRadius = 1.0;
  
  self.scrollContainer.frame = self.view.bounds;
  self.scrollContainer.scrollsToTop = NO;
  
  self.miniPlayer.frame = CGRectMake(0, 0, self.scrollContainer.frame.size.width, 50);
  
  [self.scrollContainer addSubview:self.miniPlayer];
  [self.view addSubview:self.scrollContainer];
  self.scrollContainer.contentSize = CGSizeMake(self.view.frame.size.width, 50);
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  self.scrollContainer.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)didStartPlaying:(NSNotification *)notification {
  NSLog(@"Started Playing: %@", notification.object);
}

- (void)didStopPlaying:(NSNotification *)notification {
  NSLog(@"Stopped Playing");
}

- (void)didPan:(UIPanGestureRecognizer *)panGesture {
  CGPoint location = [panGesture locationInView:self.view.superview];
  
  switch (panGesture.state) {
    case UIGestureRecognizerStateBegan:
    case UIGestureRecognizerStateChanged: {
      self.view.frame = CGRectMake(self.view.frame.origin.x, location.y, self.view.frame.size.width, self.view.frame.size.height);
    } break;
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateFailed: {
      CGFloat originToCloseTo = location.y < self.view.superview.frame.size.height/2 ? 200 : self.view.superview.frame.size.height - 50;
      [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, originToCloseTo, self.view.frame.size.width, self.view.frame.size.height);
      } completion:nil];
    } break;
    default:
      break;
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
