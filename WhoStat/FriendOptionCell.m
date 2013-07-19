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
            [self setBackgroundColor:[UIColor colorWithRed:245 green:245 blue:245 alpha:1]];
            break;
         case FriendOptionCellStyleDisabled:
            [self setBackgroundColor:[UIColor colorWithRed:166 green:166 blue:166 alpha:1]];
            [[self nameLabel] setTextColor:[UIColor whiteColor]];
            break;
        case FriendOptionCellStyleCorrect:
            [self setBackgroundColor:[UIColor colorWithRed:184 green:55 blue:29 alpha:1]];
            [[self nameLabel] setTextColor:[UIColor whiteColor]];
            break;
        case FriendOptionCellStyleIncorrect:
            [self setBackgroundColor:[UIColor colorWithRed:93 green:133 blue:21 alpha:1]];
            [[self nameLabel] setTextColor:[UIColor whiteColor]];
            break;
        default:
            break;
    }
}

@end
