//
//  LoadingAndTracksTableFooterView.h
//  SCTest
//
//  Created by Brian Michel on 3/4/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingAndTracksTableFooterView : UIView

@property (strong) NSError *error;
@property (assign) NSUInteger soundCount;
@property (copy) void(^retryBlock)(void);

- (void)startLoading;
- (void)stopLoadingWithError:(NSError *)error;

@end
