//
//  EntranceViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/27/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "EntranceViewController.h"
#import <SCGradientButton.h>

#define kEntranceViewControllerLoginButtonSize CGSizeMake(160, 50)

@interface EntranceViewController ()
@end

@implementation EntranceViewController

@synthesize loginButton = _loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    UIImage *highlightedImage = [[UIImage imageNamed:@"signin-highlighted-btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 22, 22, 22)];
    UIImage *normalImage = [[UIImage imageNamed:@"signin-normal-btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 22, 22, 22)];
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [Theme regularFontWithSize:20.0];
    _loginButton.titleLabel.shadowColor = [UIColor blackColor];
    _loginButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    _loginButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [_loginButton setImage:[UIImage imageNamed:@"soundcloud-icon-white"] forState:UIControlStateNormal];

    
    [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [_loginButton sizeToFit];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor darkGrayColor];
  [self.view addSubview:self.loginButton];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  _loginButton.frame = CGRectIntegral(CGRectMake(self.view.frame.size.width/2 - kEntranceViewControllerLoginButtonSize.width/2, self.view.frame.size.height/2 - kEntranceViewControllerLoginButtonSize.height/2, kEntranceViewControllerLoginButtonSize.width, kEntranceViewControllerLoginButtonSize.height));
}

- (void)dealloc {
  NSLog(@"EDEALLOC");
}

@end
