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

@interface TitleViewController ()

@property (strong, nonatomic) NSArray *newsFeedArray;

@end

@implementation TitleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self) {
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"WhoStat?"];
    }
    return self;
}
- (IBAction)playGame:(id)sender {
    
    if (FBSession.activeSession.isOpen) {
        NSLog(@"logged in");
    } else {
        FBSessionStateHandler handler = ^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                return;
            } else if (session.isOpen) {
                NSLog(@"successful login!");
                [self startConnectionToScrapeNewsFeed];
            }
        };
        [FBSession openActiveSessionWithReadPermissions:@[@"read_stream"]
                                           allowLoginUI:YES
                                      completionHandler:handler];
    }
    
}

- (void)startConnectionToScrapeNewsFeed
{
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                  graphPath:@"me/home?limit=50"];
    FBRequestHandler handler = ^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestForNewsFeedCompleted:connection
                                   result:result
                                    error:error];
    };
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    [connection addRequest:request
         completionHandler:handler];
    [connection start];
}

- (void)requestForNewsFeedCompleted:(FBRequestConnection *)connection
                             result:(id)result
                              error:(NSError *)error
{
    if (error) {
        NSLog(@"news feed request error");
    } else {
        NSDictionary *dictionary = (NSDictionary *)result;
        NSMutableArray *rawFeedArray = [dictionary valueForKey:@"data"];
        NSMutableArray *filteredFeedArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in rawFeedArray) {
            NSString *message = [dic objectForKey:@"message"];
            NSDictionary *from = [dic objectForKey:@"from"];
            if (message && ![from valueForKey:@"category"]) {
                NSMutableArray *item = [[NSMutableArray alloc] init];
                [item addObject:message];
                [item addObject:from];
                [filteredFeedArray addObject:item];
            }
        }
        _newsFeedArray = [[NSArray alloc] initWithArray:filteredFeedArray];
        [self startConnectionToScrapeMutualFriends];
    }
}

- (void)startConnectionToScrapeMutualFriends
{
    // Pick random friend
    uint32_t rnd = arc4random_uniform([_newsFeedArray count]);
    NSArray *correctFriendArray = _newsFeedArray[rnd];
    _currentStatus = correctFriendArray[0];
    _correctFriendDict = [[NSDictionary alloc] initWithDictionary:correctFriendArray[1]];
    
    // Start connection for mutuals
    NSString *mutualFriendGraphPath = [NSString stringWithFormat:@"me/friends"];
                                       // (int)[_correctFriendDict objectForKey:@"id"]];
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                  graphPath:mutualFriendGraphPath];
    FBRequestHandler handler = ^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestForMutualsCompleted:connection
                                  result:result
                                   error:error];
    };
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    [connection addRequest:request
         completionHandler:handler];
    
    [connection start];
}

- (void)requestForMutualsCompleted:(FBRequestConnection *)connection
                            result:(id)result
                            error:(NSError *)error
{
    
    if (error) {
        NSLog(@"mutual friend request failed");
    } else {
        NSArray *mutualsRaw = [(NSDictionary *)result objectForKey:@"data"];
        NSMutableSet *rndSet = [[NSMutableSet alloc] init];
        
        NSMutableDictionary *correctFriendDisguised = [[NSMutableDictionary alloc] initWithDictionary:_correctFriendDict];
        int friendID = (int)[correctFriendDisguised objectForKey:@"id"];
        UIImage *profilePic = [self imageForFriendID:friendID];
        [correctFriendDisguised removeObjectForKey:@"id"];
        [correctFriendDisguised setValue:profilePic forKey:@"image"];
        NSMutableArray *friendChoices = [[NSMutableArray alloc] initWithObjects:correctFriendDisguised, nil];
        
        for (int i = 0; i < 4; i++) {
            
            //Getting random mutual
            uint32_t rndIdx = arc4random_uniform([mutualsRaw count]);
            while ([rndSet containsObject:@(rndIdx)]) {
                rndIdx = arc4random_uniform([mutualsRaw count]);
            }
            [rndSet addObject:@(rndIdx)];
            
            //Adding to mutual to friend choices
            NSMutableDictionary *randomFriend = [[NSMutableDictionary alloc] initWithDictionary:mutualsRaw[rndIdx]];
            int friendID = (int)[randomFriend objectForKey:@"id"];
            UIImage *profilePic = [self imageForFriendID:friendID];
            [randomFriend removeObjectForKey:@"id"];
            [randomFriend setValue:profilePic forKey:@"image"];
            [friendChoices addObject:randomFriend];
        }
        _friendOptions = friendChoices;
    }
    [self didGetAllData];
}

- (void)didGetAllData
{
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    [gameViewController setCurrentStatus:_currentStatus];
    [[gameViewController statusTextView] setText:_currentStatus];
    [gameViewController setCorrectFriendName:[_correctFriendDict objectForKey:@"name"]];
    [gameViewController setFriendOptions:_friendOptions];
    
    [self.navigationController pushViewController:gameViewController animated:YES];
}

- (UIImage *)imageForFriendID:(int)inputID
{
    NSString *imageURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%d/picture?access_token=%@",
                                inputID, FBSession.activeSession.accessTokenData.accessToken];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
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

