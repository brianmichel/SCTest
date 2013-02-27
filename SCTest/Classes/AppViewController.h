//
//  AppViewController.h
//  SCTest
//
//  Created by Brian Michel on 2/27/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ApplicationState {
  ApplicationStateEntrance = 0,
  ApplicationStateDiscovery
} ApplicationState;

@interface AppViewController : UIViewController
@property (assign, readonly) ApplicationState currentState;

- (void)logout;
@end
