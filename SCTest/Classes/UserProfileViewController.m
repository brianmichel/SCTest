//
//  UserProfileViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/28/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "UserProfileViewController.h"
#import <UIViewController+JASidePanel.h>
#import <UIImageView+WebCache.h>
#import "ProfileView.h"
#import "BaseProfileTableViewCell.h"

NSString * const kUserProfileAPIURLString = @"https://api.soundcloud.com/me.json";
const CGFloat kUserProfileViewHeight = 150;

@interface UserProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong) UITableView *tableView;
@property (strong) NSDictionary *userHash;
@property (strong) ProfileView *profileView;
@end

@implementation UserProfileViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.profileView = [[ProfileView alloc] initWithFrame:CGRectZero];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	footerLabel.textAlignment = UITextAlignmentCenter;
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textColor = [Theme standardDarkColorWithAlpha:0.35];
    footerLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    footerLabel.shadowOffset = CGSizeMake(0, 1);
    footerLabel.font = [Theme ornamentFontWithSize:18.0];
	footerLabel.text = @"n";
	
    [footerLabel sizeToFit];
    
    self.tableView.tableFooterView = footerLabel;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view addSubview:self.profileView];
  [self.view addSubview:self.tableView];
  self.view.backgroundColor = [UIColor colorWithWhite:0.27 alpha:1.0];
	// Do any additional setup after loading the view.
  if (!self.profileView.userInformationDictionary) {
    [self loadUserProfile];
  }
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  CGFloat maxWidth = self.sidePanelController.leftVisibleWidth;
  self.profileView.frame = CGRectMake(0, 0, maxWidth, kUserProfileViewHeight);
  self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.profileView.frame), maxWidth, self.view.frame.size.height - maxWidth);
}

#pragma mark - UITableView Datasource / Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString * cellId = @"cell";
  
  BaseProfileTableViewCell *cell = (BaseProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
  
  if (!cell) {
    cell = [[BaseProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
  }
  
  switch (indexPath.row) {
    case 0:
      cell.textLabel.text = NSLocalizedString(@"Open Soundcloud", @"Open Soundcloud Application");
      cell.textLabel.textAlignment = UITextAlignmentLeft;
      break;
    case 1:
      cell.textLabel.text = NSLocalizedString(@"Logout", @"Logout");
      cell.textLabel.textAlignment = UITextAlignmentCenter;
    default:
      break;
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  switch (indexPath.row) {
    case 0: {
      NSURL *soundcloudAppURL = [NSURL URLWithString:@"soundcloud:"];
      if ([[UIApplication sharedApplication] canOpenURL:soundcloudAppURL]) {
        [[UIApplication sharedApplication] openURL:soundcloudAppURL];
      } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.soundcloud.com"]];
      }
    } break;
    case 1: {
      [APP_DELEGATE.viewController logout];
    }
    default:
      break;
  }
}

#pragma mark - Actions
- (void)loadUserProfile {
  
  __weak UserProfileViewController *weakSelf = self;
  
  SCAccount *account = [SCSoundCloud account];
  if (account == nil) {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Not Logged In"
                          message:@"You must login first"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  SCRequestResponseHandler handler;
  handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
    NSError *jsonError = nil;
    NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:0
                                         error:&jsonError];
    
    if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]]) {
      weakSelf.profileView.userInformationDictionary = (NSDictionary *)jsonResponse;
    }
  };
  
  [SCRequest performMethod:SCRequestMethodGET
                onResource:[NSURL URLWithString:kUserProfileAPIURLString]
           usingParameters:nil
               withAccount:account
    sendingProgressHandler:nil
           responseHandler:handler];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  NSLog(@"PDEALLOC");
}

@end
