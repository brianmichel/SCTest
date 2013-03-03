//
//  VinylPullToRefreshControl.h
//  SCTest
//
//  Created by Brian Michel on 3/3/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VinylPullToRefreshControl : UIControl

@property (assign, readonly, getter = isRefreshing) BOOL refreshing;

- (void)beginRefreshing;
- (void)endRefreshing;
@end
