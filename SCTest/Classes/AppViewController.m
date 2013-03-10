//
//  AppViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/27/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "AppViewController.h"
#import <SCSoundCloud.h>
#import <SCLoginViewController.h>
#import <SCUI.h>
#import <JASidePanelController.h>

#import "EntranceViewController.h"
#import "DiscoveryViewController.h"

#define kAppViewControllerDefaultTransform 

NSString * const kSCClientId = @"8918dfe0d65f3c9d0d6841ff1bcb7d46";
NSString * const kSCClientSecret = @"824197cf7d317485720eae97f01a322d";
NSString * const kSCClientRedirectURL = @"sctest://oauth";

@interface AppViewController ()
@property (strong) JASidePanelController *discoveryViewController;
@property (strong) EntranceViewController *entranceViewController;
@end

@implementation AppViewController

#pragma mark - Init
- (void)commonInit {
  [SCSoundCloud setClientID:kSCClientId secret:kSCClientSecret redirectURL:[NSURL URLWithString:kSCClientRedirectURL]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)init {
  self = [super init];
  if (self) {
    [self commonInit];
  }
  return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
  [super viewDidLoad];
  self.entranceViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.entranceViewController.view.frame = self.view.bounds;
  
  if (![SCSoundCloud account]) {
    [self setupEntranceViewController];
  } else {
    [self setupDiscoveryViewController];
  }
}

#pragma mark - Actions
- (void)login:(id)sender {
  SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
    if (SC_CANCELED(error)) {
      NSLog(@"Canceled!");
    } else if (error) {
      NSLog(@"Error: %@", [error localizedDescription]);
    } else {
      NSLog(@"Done!");
      _currentState = ApplicationStateDiscovery;
      [self setupDiscoveryViewController];
    }
    [self grow:nil];
  };
  
  [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
    SCLoginViewController *loginViewController;
    
    [self shrink:nil];
    
    loginViewController = [SCLoginViewController
                           loginViewControllerWithPreparedURL:preparedURL
                           completionHandler:handler];
    
    [self presentViewController:loginViewController animated:YES completion:^{
      _currentState = ApplicationStateEntrance;
      [self.discoveryViewController removeFromParentViewController];
      self.discoveryViewController = nil;
    }];
  }];
}

- (void)logout {
  [self shrink:^{
    [self setupEntranceViewController];
    [self grow:nil];
  }];
}

- (void)setupEntranceViewController {
  self.entranceViewController = [[EntranceViewController alloc] initWithNibName:nil bundle:nil];
  self.entranceViewController.view.frame = self.view.bounds;
  [self.entranceViewController.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
  [self addChildViewController:self.entranceViewController];
  
  if (self.discoveryViewController) {
    [self transitionFromViewController:self.discoveryViewController toViewController:self.entranceViewController duration:0.3 options:UIViewAnimationOptionTransitionFlipFromRight animations:nil completion:^(BOOL finished) {
      [self.discoveryViewController removeFromParentViewController];
      self.discoveryViewController = nil;
    }];
  } else {
    [self.view addSubview:self.entranceViewController.view];
  }
}

- (void)setupDiscoveryViewController {
  self.discoveryViewController = [[JASidePanelController alloc] init];
  DiscoveryViewController *discovery = [[DiscoveryViewController alloc] initWithNibName:nil bundle:nil];
  self.discoveryViewController.rightGapPercentage = 0.85;
  self.discoveryViewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:discovery];
  self.discoveryViewController.leftPanel = (UIViewController *)discovery.profileViewController;
  
  self.discoveryViewController.view.frame = self.view.bounds;
  [self addChildViewController:self.discoveryViewController];
  
  if (self.entranceViewController) {
    [self transitionFromViewController:self.entranceViewController toViewController:self.discoveryViewController duration:0.3 options:UIViewAnimationOptionTransitionFlipFromLeft animations:nil completion:^(BOOL finished) {
      [self.entranceViewController removeFromParentViewController];
      self.entranceViewController = nil;
    }];
  } else {
    [self.view addSubview:self.discoveryViewController.view];
  }
}

#pragma mark - Animation
- (void)shrink:(void(^)(void))callback {
  self.view.clipsToBounds = YES;
  self.view.layer.masksToBounds = YES;
  [UIView animateWithDuration:0.3 animations:^{
    self.view.transform = CGAffineTransformMakeScale(0.90, 0.90);
    self.view.alpha = 0.75;
    self.view.layer.cornerRadius = 4.0;
  } completion:^(BOOL finished) {
    if (callback) {
      callback();
    }
  }];
}

- (void)grow:(void(^)(void))callback {
  self.view.clipsToBounds = YES;
  self.view.layer.masksToBounds = YES;
  [UIView animateWithDuration:0.3 animations:^{
    self.view.transform = CGAffineTransformIdentity;
    self.view.alpha = 1.0;
    self.view.layer.cornerRadius = 0.0;
  } completion:^(BOOL finished) {
    if (callback) {
      callback();
    }
  }];
}
@end
