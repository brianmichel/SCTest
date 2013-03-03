//
//  BaseTrackTableViewCell.h
//  SCTest
//
//  Created by Brian Michel on 3/1/13.
//  Copyright (c) 2013 Foureyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTrackTableViewCell : UITableViewCell

@property (strong) NSDictionary *trackInformationDictionary;

+ (CGFloat)heightForTrackTableViewCellWithInformation:(NSDictionary *)trackInformation containedToSize:(CGSize)size;

@end
