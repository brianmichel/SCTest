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
    [hamburgerButton setImage:[UIImage imageNamed:@"hamburger-icon"] forState:UIControlStateNormal];
    hamburgerButton.showsTouchWhenHighlighted = YES;
    hamburgerButton.adjustsImageWhenHighlighted = YES;
    [hamburgerButton addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [hamburgerButton sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:hamburgerButton];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soundcloud-header-icon"]];
    [imageView sizeToFit];
    self.navigationItem.titleView = imageView;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor orangeColor];
  self.activitiesVC.view.frame = self.view.bounds;
  [self.view addSubview:self.activitiesVC.view];
}

#pragma mark - Actions
- (void)open:(id)sender {
  [self.sidePanelController showLeftPanelAnimated:YES];
}

- (void)dealloc {
  NSLog(@"DDEALLOC");
}
@end
