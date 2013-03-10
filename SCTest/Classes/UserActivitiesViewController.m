//
//  UserActivitiesViewController.m
//  SCTest
//
//  Created by Brian Michel on 2/27/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import "UserActivitiesViewController.h"
#import "BaseTrackTableViewCell.h"
#import "StatusBackgroundTableView.h"
#import "VinylPullToRefreshControl.h"
#import "LoadingAndTracksTableFooterView.h"
#import "SCActivity.h"
#import "SCMedia.h"

NSString * const kUserActivitiesNextHREFKey = @"next_href";
NSString * const kUserActivitiesFutureHREFKey = @"future_href";
NSString * const kUserActivitiesCollectionsKey = @"collection";

@interface UserActivitiesViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (strong) NSURL *nextHREFToLoad;
@property (strong) NSURL *futureHREF;
@property (strong) StatusBackgroundTableView *tableView;
@property (strong) NSMutableArray *activities;
@property (assign) BOOL loadingMore;
@end

@implementation UserActivitiesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [SCPlayer sharedPlayer].autoplay = YES;
    self.tableView = [[StatusBackgroundTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [Theme	standardLightWhiteColorWithAlpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    
    self.tableView.tableFooterView = [[LoadingAndTracksTableFooterView alloc] initWithFrame:CGRectMake(0, 0, 0, kVinylPullToRefreshControlHeight)];
    self.tableView.tableFooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    VinylPullToRefreshControl *pullToRefreshControl = [[VinylPullToRefreshControl alloc] init];
    [pullToRefreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.tableHeaderView = pullToRefreshControl;
    self.tableView.contentInset = UIEdgeInsetsMake(-(kVinylPullToRefreshControlHeight), 0, 50, 0);
    
    self.tableView.displayImage = [UIImage imageNamed:@"no-data-bkg"];
    self.tableView.displayString = NSLocalizedString(@"No Tracks", @"No Tracks To Display Placeholder");
    
    self.activities = [NSMutableArray arrayWithCapacity:0];
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
  return [self.activities count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  SCActivity *activity = [self.activities objectAtIndex:indexPath.row];
  //cheaply filter out the activities that aren't of type 'track'
  if (activity.activityType == SC_ACTIVITY_TYPE_TRACK) {
	return [BaseTrackTableViewCell heightForTrackTableViewCellWithInformation:activity containedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)];
  }

  return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString * cellId = @"cell";
  
  BaseTrackTableViewCell *cell = (BaseTrackTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
  
  if (!cell) {
    cell = [[BaseTrackTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
  }
  
  SCActivity *activity = [self.activities objectAtIndex:indexPath.row]; 
  cell.trackActivity = activity;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  SCActivity *activity = [self.activities objectAtIndex:indexPath.row];
#if USE_PLAYER
  if (activity.media.mediaType == SC_MEDIA_TYPE_TRACK) {
    SCTrack *track = (SCTrack *)activity.media;
    [[SCPlayer sharedPlayer] playTrack:track];
  }
#else
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:tracks:%i", activity.media.mediaID]];
  NSURL *permaLink = activity.media.permalinkURL;
  
  //Give priority to SC App, fail over to web.
  if ([[UIApplication sharedApplication] canOpenURL:url]) {
    [[UIApplication sharedApplication] openURL:url];
  } else if	(permaLink) {
    [[UIApplication sharedApplication] openURL:permaLink];
  }
#endif
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
                          initWithTitle:NSLocalizedString(@"Not Logged In", @"Not Logged In Alert Title")
                          message:NSLocalizedString(@"You must login first", @"Not Logged In Alert Body")
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString (@"OK", nil)
                          otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  //if we've retreived tracks before, but were unable
  //get the next url cursor, bail.
  if ([self.activities count] && !self.nextHREFToLoad) {
    return;
  }
  __weak UserActivitiesViewController *weakSelf = self;

  LoadingAndTracksTableFooterView *indicator = (LoadingAndTracksTableFooterView *)self.tableView.tableFooterView;
  indicator.retryBlock = ^{
    [weakSelf loadNextTracks];
  };
  [indicator startLoading];
  
  NSURL *resourceURL = !self.nextHREFToLoad ? [NSURL URLWithString:@"https://api.soundcloud.com/me/activities.json"] : self.nextHREFToLoad;
  
  SCRequestResponseHandler handler;
  handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
    if (!error) {
      NSError *jsonError = nil;
      NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
      
      if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionaryResponse = (NSDictionary *)jsonResponse;
        NSString *nextHREF = [self splitStringAndAddJSON:dictionaryResponse[kUserActivitiesNextHREFKey]];
        NSURL	*futureHREF = [NSURL URLWithString:[self splitStringAndAddJSON:dictionaryResponse[kUserActivitiesFutureHREFKey]]];
        
        //pretty sure we only need to set this once...
        if (!weakSelf.futureHREF && futureHREF) {
          weakSelf.futureHREF = futureHREF;
        }
        
        NSArray *collection = dictionaryResponse[kUserActivitiesCollectionsKey];
        if (!collection || !nextHREF) {
          NSLog(@"DICT: %@", dictionaryResponse);
        }
        weakSelf.nextHREFToLoad = !nextHREF ? nil : [NSURL URLWithString:nextHREF];
        [weakSelf mergeNewActivities:collection onTop:NO];
        
        weakSelf.loadingMore = NO;
        [weakSelf.tableView flashScrollIndicators];
      }
    } else {
      weakSelf.loadingMore = NO;
    }
    [indicator stopLoadingWithError:error];
  };
  
  self.loadingMore = YES;
  [SCRequest performMethod:SCRequestMethodGET
                onResource:resourceURL
           usingParameters:nil
               withAccount:account
    sendingProgressHandler:nil
           responseHandler:handler];
}

- (void)mergeNewActivities:(NSArray *)activitiesCollection onTop:(BOOL)onTop {
  [self.tableView beginUpdates];
  NSInteger beginIndex = onTop ? 0 :[self.activities count];
  NSMutableArray *indiciesToInsert = [NSMutableArray arrayWithCapacity:[activitiesCollection count]];
  NSMutableArray *activititesArray = [NSMutableArray arrayWithCapacity:[activitiesCollection count]];
  
  for (NSDictionary *activityDictionary in activitiesCollection) {
    SCActivity *activity = [[SCActivity alloc] initWithDictionary:activityDictionary];
	[activititesArray addObject:activity];
    [indiciesToInsert addObject:[NSIndexPath indexPathForRow:beginIndex++ inSection:0]];
  }
  [self.tableView insertRowsAtIndexPaths:indiciesToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
  
  if (onTop) {
    [self.activities insertObjects:activititesArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [activititesArray count])]];
  } else {
    [self.activities addObjectsFromArray:activititesArray];
  }
  
  [self.tableView endUpdates];
  
  LoadingAndTracksTableFooterView *footer = (LoadingAndTracksTableFooterView *)self.tableView.tableFooterView;
  footer.soundCount = [self.activities count];
}

- (void)refresh:(id)sender {
  VinylPullToRefreshControl *control = sender;
  
  if (self.futureHREF) {
    [control beginRefreshing];
    self.tableView.displayString = @"Loading...";
    
    SCAccount *account = [SCSoundCloud account];
    __weak UserActivitiesViewController *weakSelf = self;
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
      if (!error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]]) {
          NSDictionary *dictionaryResponse = (NSDictionary *)jsonResponse;
          weakSelf.futureHREF = [NSURL URLWithString:[self splitStringAndAddJSON:dictionaryResponse[kUserActivitiesFutureHREFKey]]];
          NSArray *collection = dictionaryResponse[kUserActivitiesCollectionsKey];
          [weakSelf mergeNewActivities:collection onTop:YES];
          
          [weakSelf.tableView flashScrollIndicators];
        }
      }
      [control endRefreshing];
    };
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:self.futureHREF
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
  } else {
    [control endRefreshing];
  }
}

- (NSString *)splitStringAndAddJSON:(NSString *)urlString {
  /*begin ghetto
   It looks like the next_href doesn't respect the initial request type.
   If we could set the accepts header on the request we'd be fine too,
   but we can't because it's private. We could ALSO register a new URL
   protocol handler, but that's really not worth it.
   */
  NSArray *comps = [urlString componentsSeparatedByString:@"?"];
  NSString *returnString = nil;
  if ([comps count] == 2) {
    returnString = [NSString stringWithFormat:@"%@.json?%@", comps[0], comps[1]];
  }
  //end ghetto
  return returnString;
}

- (void)dealloc {
  NSLog(@"UADEALLOC");
}

@end
