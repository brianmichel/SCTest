//
//  BaseTrackTableViewCell.h
//  SCTest
//
//  Created by Brian Michel on 3/1/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCActivity;
@interface BaseTrackTableViewCell : UITableViewCell

@property (strong) SCActivity *trackActivity;

+ (CGFloat)heightForTrackTableViewCellWithInformation:(SCActivity *)trackActivity containedToSize:(CGSize)size;

@end
