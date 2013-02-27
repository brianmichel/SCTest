//
//  DiscoveryViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/27/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "DiscoveryViewController.h"

@implementation DiscoveryViewController

@synthesize logoutButton = _logoutButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
	_logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[_logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
	[_logoutButton sizeToFit];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor orangeColor];
  [self.view addSubview:self.logoutButton];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  _logoutButton.frame = CGRectIntegral(CGRectMake(self.view.frame.size.width/2 - _logoutButton.frame.size.width/2, self.view.frame.size.height/2 - _logoutButton.frame.size.height/2, _logoutButton.frame.size.width, _logoutButton.frame.size.height));
}
@end
