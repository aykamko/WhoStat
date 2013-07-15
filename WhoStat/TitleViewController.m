//
//  TitleViewController.m
//  WhoStat
//
//  Created by Ashwin Murthy on 7/11/13.
//  Copyright (c) 2013 Ashwin Murthy. All rights reserved.
//

#import "TitleViewController.h"
#import "GameViewController.h"
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
        [navigationItem setTitle:@"WhoStat?"];
    }
    return self;
}

- (IBAction)playGame:(id)sender {
    [[FBRequestController sharedController] setDelegate:self];
    [[FBRequestController sharedController] startScrapingFacebookData];
}

- (void)didGetRoundData:(NSDictionary *)round {
    
    [[GameRoundQueue sharedQueue] pushRound:round];
    NSLog(@"rounds: %i", [[GameRoundQueue sharedQueue] queueLength]);
    if ([[GameRoundQueue sharedQueue] queueLength] < 3) {
        NSLog(@"starting again");
        [[FBRequestController sharedController] startScrapingFacebookData];
    }
    if ([[self.navigationController viewControllers]
         containsClass:[GameViewController class]]) {
        NSLog(@"GameViewController already on navigationController stack");
        return;
    }
    
    GameViewController *gameViewController =
        [[GameViewController alloc]
         initWithNibName:@"GameViewController"
         bundle:nil];
    
    [self.navigationController pushViewController:gameViewController
                                         animated:YES];
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

