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
    [gameViewController setUpNextRound:round];
    
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

