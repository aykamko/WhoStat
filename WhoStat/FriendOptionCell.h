//
//  FriendOptionCell.h
//  WhoStat
//
//  Created by Dan Schlosser on 7/11/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FriendOptionCellStyle) {
    FriendOptionCellStyleNone,
    FriendOptionCellStyleCorrect,
    FriendOptionCellStyleIncorrect,
    FriendOptionCellStyleDisabled
};

@interface FriendOptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) id controller;

- (void)changeStyle:(FriendOptionCellStyle)style;

@end
