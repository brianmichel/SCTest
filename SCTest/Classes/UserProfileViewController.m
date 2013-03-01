//
//  UserProfileViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/28/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "UserProfileViewController.h"
#import <UIViewController+JASidePanel.h>

@interface UserProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong) UIImageView *avatarImageView;
@property (strong) UITableView *tableView;
@end

@implementation UserProfileViewController

@synthesize avatarImageView = _avatarImageView;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.avatarImageView.backgroundColor = [UIColor brownColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view addSubview:self.avatarImageView];
  [self.view addSubview:self.tableView];
	// Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  CGFloat maxWidth = self.sidePanelController.leftVisibleWidth;
  self.avatarImageView.frame = CGRectMake(0, 0, maxWidth, maxWidth);
  self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.avatarImageView.frame), maxWidth, self.view.frame.size.height - maxWidth);
}

#pragma mark - UITableView Datasource / Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString * cellId = @"cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
  }
  
  cell.textLabel.text = [indexPath description];
  return cell;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
