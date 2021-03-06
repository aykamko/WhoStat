//
//  GameViewController.h
//  WhoStat
//
//  Created by Dan Schlosser on 7/11/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameViewController;

@protocol GameViewControllerDelegate <NSObject>

- (void)gameViewControllerDidFinishRound:(GameViewController *)gvc;
- (void)gameViewControllerShouldExit:(GameViewController *)gvc;

@end

@interface GameViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) id <GameViewControllerDelegate> delegate;

@property (nonatomic) int currentStreak;


// Spinner if waiting for new round
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

// TableView below

@property (strong, nonatomic) NSArray *friendOptions;

- (void)setUpNextRound:(NSDictionary *)round withCurrentStreak:(int)streak;

@end
