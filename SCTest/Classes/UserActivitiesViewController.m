//
//  UserActivitiesViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/27/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "UserActivitiesViewController.h"
#import "BaseTrackTableViewCell.h"

NSString * const kUserActivitiesNextHREFKey = @"next_href";
NSString * const kUserActivitiesCollectionsKey = @"collection";

@interface UserActivitiesViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (strong) NSURL *nextHREFToLoad;
@property (strong) UITableView *tableView;
@property (strong) NSMutableArray *tracks;
@property (assign) BOOL loadingMore;
@end

@implementation UserActivitiesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor colorWithRed:229/256.0 green:229/256.0 blue:229/256.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tracks = [NSMutableArray arrayWithCapacity:0];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.frame = self.view.bounds;
  [self.view addSubview:self.tableView];
  [self loadNextTracks];
}

#pragma mark - UITableView Datasource / Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.tracks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
  return [BaseTrackTableViewCell heightForTrackTableViewCellWithInformation:track containedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString * cellId = @"cell";
  
  BaseTrackTableViewCell *cell = (BaseTrackTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
  
  if (!cell) {
    cell = [[BaseTrackTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
  }
  
  NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
  cell.trackInformationDictionary = track;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
  
  NSLog(@"TRACK: %@", track);
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:tracks:%@", [track valueForKeyPath:@"origin.id"]]];
  
  if ([[UIApplication sharedApplication] canOpenURL:url]) {
    [[UIApplication sharedApplication] openURL:url];
  }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (scrollView.contentOffset.y / scrollView.contentSize.height >= 0.6) {
    [self loadNextTracks];
  }
}

#pragma mark - Actions
- (void)loadNextTracks {
  if (self.loadingMore) {return;}
  
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
  
  //if we've retreived tracks before, but were unable
  //get the next url cursor, bail.
  if ([self.tracks count] && !self.nextHREFToLoad) {
    return;
  }
  
  NSURL *resourceURL = !self.nextHREFToLoad ? [NSURL URLWithString:@"https://api.soundcloud.com/me/activities.json"] : self.nextHREFToLoad;
  
  SCRequestResponseHandler handler;
  handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
    NSError *jsonError = nil;
    NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:0
                                         error:&jsonError];
    
    if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]]) {
      NSDictionary *dictionaryResponse = (NSDictionary *)jsonResponse;
      NSString *nextHREF = dictionaryResponse[kUserActivitiesNextHREFKey];
      
      /*begin ghetto
       It looks like the next_href doesn't respect the initial request type.
       */
      NSArray *comps = [nextHREF componentsSeparatedByString:@"?"];
      if ([comps count] == 2) {
        nextHREF = [NSString stringWithFormat:@"%@.json?%@", comps[0], comps[1]];
      }
      //end ghetto
      NSArray *collection = dictionaryResponse[kUserActivitiesCollectionsKey];
      self.nextHREFToLoad = !nextHREF ? nil : [NSURL URLWithString:nextHREF];
      [self mergeNewTracks:collection];
      self.loadingMore = NO;
    }
  };
  
  self.loadingMore = YES;
  [SCRequest performMethod:SCRequestMethodGET
                onResource:resourceURL
           usingParameters:nil
               withAccount:account
    sendingProgressHandler:nil
           responseHandler:handler];
}

- (void)mergeNewTracks:(NSArray *)tracksCollection {
  [self.tracks addObjectsFromArray:tracksCollection];
  [self.tableView reloadData];
}

- (void)dealloc {
  NSLog(@"UADEALLOC");
}

@end
