//
//  TitleViewController.h
//  WhoStat
//
//  Created by Ashwin Murthy on 7/11/13.
//  Copyright (c) 2013 Ashwin Murthy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *questionMark;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) NSDictionary *correctFriendDict;
@property (strong, nonatomic) NSString *currentStatus;
@property (strong, nonatomic) NSArray *friendOptions;

@end
