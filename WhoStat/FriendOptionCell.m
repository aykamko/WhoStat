//
//  FriendOptionCell.m
//  WhoStat
//
//  Created by Dan Schlosser on 7/11/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "FriendOptionCell.h"


@implementation FriendOptionCell

-(void)changeStyle:(FriendOptionCellStyle)style {
    switch (style) {
        case FriendOptionCellStyleNone:
            [self.contentView  setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1]];
            break;
         case FriendOptionCellStyleDisabled:
            [self.contentView setBackgroundColor:[UIColor colorWithRed:166.0f/255.0f green:166.0f/255.0f blue:166.0f/255.0f alpha:1]];
            [[self nameLabel] setTextColor:[UIColor whiteColor]];
            break;
        case FriendOptionCellStyleCorrect:
            [self.contentView setBackgroundColor:[UIColor colorWithRed:184.0f/255.0f green:55.0f/255.0f blue:29.0f/255.0f alpha:1]];
            [[self nameLabel] setTextColor:[UIColor whiteColor]];
            break;
        case FriendOptionCellStyleIncorrect:
            [self.contentView setBackgroundColor:[UIColor colorWithRed:93.0f/255.0f green:133.0f/255.0f blue:21.0f/255.0f alpha:1]];
            [[self nameLabel] setTextColor:[UIColor whiteColor]];
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

@end
