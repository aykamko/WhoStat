//
//  GameViewController.h
//  WhoStat
//
//  Created by Dan Schlosser on 7/11/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameViewControllerDelegate <NSObject>

- (void)didFinishRound;

@end

@interface GameViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) id <GameViewControllerDelegate> delegate;

// The status



// TableView below

@property (strong, nonatomic) NSArray *friendOptions;

- (void)setUpNextRound:(NSDictionary *)round;

@end
