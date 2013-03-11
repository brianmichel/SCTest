//
//  DiscoveryViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/27/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "UserActivitiesViewController.h"
#import "UserProfileViewController.h"

@interface DiscoveryViewController()
@property (strong) UserActivitiesViewController *activitiesVC;
@end

@implementation DiscoveryViewController

@synthesize profileViewController = _profileViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    _profileViewController = [[UserProfileViewController alloc] initWithNibName:nil bundle:nil];
    
    self.activitiesVC = [[UserActivitiesViewController alloc] initWithNibName:nil bundle:nil];
    
    UIButton *hamburgerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hamburgerButton addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [hamburgerButton setImage:[UIImage imageNamed:@"hamburger-icon"] forState:UIControlStateNormal];
    hamburgerButton.showsTouchWhenHighlighted = YES;
    hamburgerButton.accessibilityLabel = NSLocalizedString(@"Reveal Navigation", @"Reveal Navigation Button");
    [hamburgerButton sizeToFit];

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:hamburgerButton];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soundcloud-icon-gray"]];
    [imageView sizeToFit];
    self.navigationItem.titleView = imageView;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.activitiesVC.view.frame = self.view.bounds;  
  [self.view addSubview:self.activitiesVC.view];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  [self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

#pragma mark - Actions
- (void)open:(id)sender {
  [self.sidePanelController showLeftPanelAnimated:YES];
}

- (void)openNowPlaying:(id)sender {
  [self.sidePanelController showRightPanelAnimated:YES];
}

#pragma mark - Remote Event Callback
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
  switch (event.subtype) {
    case UIEventSubtypeRemoteControlPause:
    case UIEventSubtypeRemoteControlStop:
      [[SCPlayer sharedPlayer] pause];
      break;
    case UIEventSubtypeRemoteControlPlay:
      [[SCPlayer sharedPlayer] play];
      break;
    case UIEventSubtypeRemoteControlTogglePlayPause: {
      if ([SCPlayer sharedPlayer].playing) {
        [[SCPlayer sharedPlayer] pause];
      } else {
        [[SCPlayer sharedPlayer] play];
      }
    } break;
    default:
      break;
  }
}

- (void)dealloc {
  NSLog(@"DDEALLOC");
}
@end
