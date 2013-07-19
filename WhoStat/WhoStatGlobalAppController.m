//
//  WhoStatGlobalAppController.m
//  WhoStat
//
//  Created by Aleks Kamko on 7/15/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "WhoStatGlobalAppController.h"
#import "TitleViewController.h"
#import "GameViewController.h"
#import "FBRequestController.h"
#import "GameRoundQueue.h"

@interface WhoStatGlobalAppController () {
    int _currentStreak;
}

@property (nonatomic, strong) FBRequestController *requestController;
@property (nonatomic, strong) GameRoundQueue *gameRoundQueue;

@property (nonatomic, weak) TitleViewController *titleViewController;
@property (nonatomic, weak) GameViewController *gameViewController;

@property (nonatomic) BOOL gamePlaying;
@property (nonatomic) BOOL roundFinished;

@end

@implementation WhoStatGlobalAppController

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _longestStreak = [[NSNumber alloc] initWithInt:0];
        _gamePlaying = NO;
        _roundFinished = NO;
        _requestController = [[FBRequestController alloc] init];
        _gameRoundQueue = [[GameRoundQueue alloc] init];
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self appController];
}

+ (WhoStatGlobalAppController *)appController
{
    static WhoStatGlobalAppController *appController = nil;
    if (!appController) {
        appController = [[super allocWithZone:nil] init];
    }
    return appController;
}

- (void)setLongestStreak:(NSNumber *)longestStreak
{
    _longestStreak = longestStreak;
    [_titleViewController setLongestStreak:longestStreak];
}

- (void)startNewRequest
{
    if (([_gameRoundQueue queueLength] < 10) &&
        ![_requestController isScraping]) {
//        NSLog(@"starting");
        void (^completion)(NSDictionary *round);
        completion = ^(NSDictionary *round) {
            [_gameRoundQueue pushRound:round];
//            NSLog(@"queued: %d", [_gameRoundQueue queueLength]);
            if (_roundFinished == YES || _gamePlaying == NO) {
                [self sendNewRoundToGameViewController];
            }
            [self startNewRequest];
        };
        [_requestController
         startScrapingFacebookDataWithCompletionBlock:completion];
    }
}

- (void)setUpNewGame
{
    if ([[GameRoundQueue sharedQueue] queueLength] == 0) {
        [_titleViewController startIndicatorAnimation];
        [self startNewRequest];
    } else {
        [self sendNewRoundToGameViewController];
    }
}

- (void)gameViewControllerDidFinishRound:(GameViewController *)gvc
{
    _currentStreak = [gvc currentStreak];
    [self startNewRequest];
}


- (void)gameViewControllerShouldExit:(GameViewController *)gvc
{
    _roundFinished = YES;
    if ([_gameRoundQueue queueLength] > 0) {
        [self sendNewRoundToGameViewController];
    }
}

- (void)sendNewRoundToGameViewController
{
    NSDictionary *nextRound = [_gameRoundQueue popRound];
    _roundFinished = NO;
    GameViewController *newGameViewController =
        [[GameViewController alloc]
         initWithNibName:@"GameViewController" bundle:nil];
    [newGameViewController setDelegate:self];
    
    if (!_gameViewController) {
        [_titleViewController stopIndicatorAnimation];
        [newGameViewController setUpNextRound:nextRound withCurrentStreak:0];
        _gamePlaying = YES;
    } else {
        [newGameViewController setUpNextRound:nextRound
                         withCurrentStreak:_currentStreak];
    }
    
    [[self navController] setViewControllers:@[_titleViewController,
                                              newGameViewController]
                                    animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[TitleViewController class]]) {
        _titleViewController = (TitleViewController *) viewController;
    } else if ([viewController isKindOfClass:[GameViewController class]]) {
        _gameViewController = (GameViewController *) viewController;
    }
}

@end
