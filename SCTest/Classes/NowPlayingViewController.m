//
//  NowPlayingViewController.m
//  SCTest
//
//  Created by Brian Michel on 3/6/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "NowPlayingViewController.h"

@interface NowPlayingViewController ()

@end

@implementation NowPlayingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartPlaying:) name:kSCPlayerBeginPlayback object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStopPlaying:) name:kSCPlayerStopPlayback object:nil];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor darkGrayColor];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

#pragma mark - Actions
- (void)didStartPlaying:(NSNotification *)notification {
  NSLog(@"Started Playing: %@", notification.object);
}

- (void)didStopPlaying:(NSNotification *)notification {
  NSLog(@"Stopped Playing");
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
