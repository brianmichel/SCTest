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
    _profileViewController.view.backgroundColor = [UIColor blueColor];
    
    self.activitiesVC = [[UserActivitiesViewController alloc] initWithNibName:nil bundle:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStyleBordered target:self action:@selector(open:)];
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
