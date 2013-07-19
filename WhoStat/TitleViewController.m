//
//  TitleViewController.m
//  WhoStat
//
//  Created by Ashwin Murthy on 7/11/13.
//  Copyright (c) 2013 Ashwin Murthy. All rights reserved.
//

#import "TitleViewController.h"
#import "GameViewController.h"
#import "WhoStatGlobalAppController.h"

#import "WhoStatAppDelegate.h"
#import "FBRequestController.h"
#import "NSMutableArray+Shuffling.h"
#import "NSArray+ContainsClass.h"
#import "GameRoundQueue.h"

@interface TitleViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *questionMark;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation TitleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self) {
        UINavigationItem *navigationItem = [self navigationItem];
        [navigationItem setTitle:@"Home"];
    }
    return self;
}

- (IBAction)playGame:(id)sender {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.playButton.bounds.size.height / 2;
    CGFloat halfButtonWidth = self.playButton.bounds.size.width / 2;
    indicator.center = CGPointMake(halfButtonWidth , halfButtonHeight);
    [self.playButton setTitle:@"" forState:UIControlStateNormal];
    [self.playButton addSubview:indicator];
    [indicator startAnimating];
    [self.delegate setUpGame];
}

- (void)pushGameViewControllerWithRound:(NSDictionary *)round
{
//    if ([[self.navigationController viewControllers]
//         containsClass:[GameViewController class]]) {
//        return;
//    }
    
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    [gameViewController setDelegate:[self delegate]];
    [gameViewController setUpNextRound:round withCurrentStreak:0];
    [self.navigationController pushViewController:gameViewController
                                         animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

