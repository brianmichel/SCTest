//
//  EntranceViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/27/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "EntranceViewController.h"
#import <SCGradientButton.h>

@interface EntranceViewController ()
@end

@implementation EntranceViewController

@synthesize loginButton = _loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {    
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [_loginButton sizeToFit];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor magentaColor];
  [self.view addSubview:self.loginButton];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  _loginButton.frame = CGRectIntegral(CGRectMake(self.view.frame.size.width/2 - _loginButton.frame.size.width/2, self.view.frame.size.height/2 - _loginButton.frame.size.height/2, _loginButton.frame.size.width, _loginButton.frame.size.height));
}

@end
