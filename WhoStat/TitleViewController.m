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
#import "CreditsViewController.h"

#import "WhoStatAppDelegate.h"
#import "FBRequestController.h"
#import "NSMutableArray+Shuffling.h"
#import "NSArray+ContainsClass.h"
#import "GameRoundQueue.h"

@interface TitleViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *questionMark;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *creditsButton;
@property (weak, nonatomic) IBOutlet UILabel *longestStreakLabel;

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

- (IBAction)showCredits:(id)sender {
    CreditsViewController *creditsViewController =
    [[CreditsViewController alloc] initWithNibName:@"CreditsViewController"
                                            bundle:nil];
    [self.navigationController pushViewController:creditsViewController
                                         animated:YES];
}

- (IBAction)playGame:(id)sender {
    [self.delegate setUpNewGame];
}

- (void)startIndicatorAnimation
{
    _indicator = [[UIActivityIndicatorView alloc]
                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.playButton.bounds.size.height / 2;
    CGFloat halfButtonWidth = self.playButton.bounds.size.width / 2;
    _indicator.center = CGPointMake(halfButtonWidth , halfButtonHeight);
    [self.playButton setTitle:@"" forState:UIControlStateNormal];
    [self.playButton addSubview:_indicator];
    [_indicator startAnimating];
}

- (void)stopIndicatorAnimation
{
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.playButton setNeedsDisplay];
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
    [[self creditsButton].layer setCornerRadius:2.0];
    [[self creditsButton] addTarget:self
                             action:@selector(buttonHighlight:)
                   forControlEvents:UIControlEventTouchDown];
    [[self creditsButton] addTarget:self
                             action:@selector(buttonNormal:)
                   forControlEvents:UIControlEventTouchUpInside];
    [[self playButton].layer setCornerRadius:2.0];
    [[self playButton] addTarget:self
                          action:@selector(buttonHighlight:)
                forControlEvents:UIControlEventTouchDown];
    [[self playButton] addTarget:self
                          action:@selector(buttonNormal:)
                forControlEvents:UIControlEventTouchUpInside];
    [[self longestStreakLabel]
     setText:[NSString stringWithFormat:@"Longest streak: %@",
              [self longestStreak]]];
}

- (void)buttonHighlight:(UIButton *)button
{
    [button setBackgroundColor:[UIColor colorWithRed:208.0/255.0f green:216.0/255.0f blue:237.0/255.0f alpha:1]];
    [button setNeedsDisplay];
}

- (void)buttonNormal:(UIButton *)button
{
    [button setBackgroundColor:[UIColor colorWithRed:196.0/255.0f green:204.0/255.0f blue:223.0/255.0f alpha:1]];
    [button setNeedsDisplay];
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

