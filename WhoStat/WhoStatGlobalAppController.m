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
        _gamePlaying = NO;
        _roundFinished = NO;
        _requestController = [[FBRequestController alloc] init];
        [_requestController setDelegate:self];
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

- (void)setUpGame
{
    if ([[GameRoundQueue sharedQueue] queueLength] == 0) {
        [[FBRequestController sharedController] startScrapingFacebookData];
    }
}

- (void)didGetRoundData:(NSDictionary *)round
{
    [_gameRoundQueue pushRound:round];
    NSLog(@"rounds: %d", [_gameRoundQueue queueLength]);
    if (([_gameRoundQueue queueLength] < 5) &&
        (![_requestController isScraping])) {
        [_requestController startScrapingFacebookData];
    }
    if (_roundFinished == YES || _gamePlaying == NO) {
        [self sendNewRoundToGameViewController];
    }
}

- (void)gameViewControllerDidFinishRound:(GameViewController *)gvc
{
    _roundFinished = YES;
    _currentStreak = [gvc currentStreak];
    if (([_gameRoundQueue queueLength] < 5) &&
        (![_requestController isScraping])) {
        [_requestController startScrapingFacebookData];
    }
    if ([_gameRoundQueue queueLength] > 0) {
        [self sendNewRoundToGameViewController];
    }
}

- (void)sendNewRoundToGameViewController
{
    NSDictionary *nextRound = [_gameRoundQueue popRound];
    if (!_gameViewController) {
        [[self titleViewController] pushGameViewControllerWithRound:nextRound];
        _roundFinished = NO;
    }
    [_gameViewController setUpNextRound:nextRound withCurrentStreak:_currentStreak];
    _roundFinished = NO;
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[TitleViewController class]]) {
        _titleViewController = (TitleViewController *) viewController;
    } else if ([viewController isKindOfClass:[GameViewController class]]) {
        _gameViewController = (GameViewController *) viewController;
        _gamePlaying = YES;
    }
}

@end
