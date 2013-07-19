//
//  TitleViewController.h
//  WhoStat
//
//  Created by Ashwin Murthy on 7/11/13.
//  Copyright (c) 2013 Ashwin Murthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBRequestController.h"
#import "GameViewController.h"

@protocol TitleViewControllerDelegate <NSObject>

- (void)setUpNewGame;

@end

@interface TitleViewController : UIViewController

@property (nonatomic, strong) id <TitleViewControllerDelegate, GameViewControllerDelegate> delegate;
- (void)pushGameViewControllerWithRound:(NSDictionary *)round;

@end
