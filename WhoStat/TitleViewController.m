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
@property int pulledPicCount;
@property NSMutableDictionary *tempImageStore;

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
    FBRequest *request = [[FBRequest alloc]
                          initWithSession:FBSession.activeSession
                          graphPath:@"me/home?fields=from,message&with=message&limit=30"];
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
        NSArray *feedArray = [(NSDictionary *)result valueForKey:@"data"];
        NSDictionary *correctFriendDict;
        while (!(correctFriendDict[@"message"]) ||
               (correctFriendDict[@"from"][@"category"])) {
            uint32_t rnd = arc4random_uniform([feedArray count]);
            correctFriendDict = feedArray[rnd];
        }
        _correctFriendDict = correctFriendDict;
        _currentStatus = [_correctFriendDict valueForKey:@"message"];
        [self startConnectionToScrapeFriendData];
    }
}

- (void)startConnectionToScrapeFriendData
{
    // Query building
    NSString *correctFriendQuery =
    [NSString
     stringWithFormat:@"SELECT uid, name, pic_small FROM user WHERE uid = %@",
     [[_correctFriendDict objectForKey:@"from"] objectForKey:@"id"]];
 //    NSString *friendsFriendIDQuery = [NSString
//                                      stringWithFormat:@"SELECT uid2 FROM friend WHERE uid1 = %@",
//                                      [[_correctFriendDict objectForKey:@"from"] objectForKey:@"id"]];
//    NSString *mutualFriendDataQuery = [NSString
//                                       stringWithFormat:@"SELECT uid, name, pic_small FROM user WHERE uid IN (%@) AND uid IN (%@)",
//                                       myFriendIDQuery, friendsFriendIDQuery];
    NSString *myFriendIDQuery = @"SELECT uid2 FROM friend WHERE uid1 = me()";
    NSString *myFriendDataQuery =
    [NSString
     stringWithFormat:@"SELECT uid, name, pic_small FROM user WHERE uid IN (%@)",
     myFriendIDQuery];
    NSString *compoundQuery =
    [NSString
     stringWithFormat:@"{\"correct\":\"%@\", \"friends\":\"%@\"}",
     correctFriendQuery, myFriendDataQuery];
    
    NSDictionary *queryParam = @{ @"q": compoundQuery };
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestForFriendDataCompleted:connection
                                     result:result
                                      error:error];
    };
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:handler];
}

- (void)requestForFriendDataCompleted:(FBRequestConnection *)connection
                               result:(id)result
                                error:(NSError *)error
{
    if (error) {
        NSLog(@"friend data request failed");
    } else {
        NSArray *rawData = [(NSDictionary *)result objectForKey:@"data"];
        NSMutableDictionary *correctFriendDisquised =
            [(NSDictionary *)rawData[0] objectForKey:@"fql_result_set"][0];
//        NSArray *mutualsRaw = [(NSDictionary *)rawData[1] objectForKey:@"fql_result_set"];
        NSArray *friendRaw =
            [(NSDictionary *)rawData[1] objectForKey:@"fql_result_set"];
        
        NSURL *imageURL = [NSURL
                           URLWithString:correctFriendDisquised[@"pic_small"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        [correctFriendDisquised removeObjectForKey:@"pic_small"];
        [correctFriendDisquised setObject:image forKey:@"image"];
        
        NSMutableArray *friendChoices =
            [[NSMutableArray alloc]
             initWithObjects:correctFriendDisquised, nil];
        
        

        NSArray *chosenArray = friendRaw;
        for (int i = 0; i < 4; i++) {
            NSMutableSet *rndSet = [[NSMutableSet alloc] init];
            uint32_t rndIdx = arc4random_uniform([chosenArray count]);
            while ([rndSet containsObject:@(rndIdx)]) {
                rndIdx = arc4random_uniform([chosenArray count]);
            }
            [rndSet addObject:@(rndIdx)];
            
            NSMutableDictionary *randomFriend = chosenArray[rndIdx];
            NSURL *imageURL = [NSURL URLWithString:randomFriend[@"pic_small"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            [randomFriend removeObjectForKey:@"pic_small"];
            [randomFriend setObject:image forKey:@"image"];
            
            [friendChoices addObject:[chosenArray objectAtIndex:rndIdx]];
        }
        _friendOptions = friendChoices;
    }
    [self didGetAllData];
}

//- (void)requestForMutualsCompleted:(FBRequestConnection *)connection
//                            result:(id)result
//                            error:(NSError *)error
//{
//    if (error) {
//        NSLog(@"mutual friend request failed");
//    } else {
//        NSArray *mutualsRaw = [(NSDictionary *)result objectForKey:@"data"];
//        NSMutableSet *rndSet = [[NSMutableSet alloc] init];
//        _pulledPicCount = 0;
//        _tempImageStore = [[NSMutableDictionary alloc] init];
//        
//        NSMutableDictionary *correctFriendDisguised = [[NSMutableDictionary alloc] initWithDictionary:_correctFriendDict];
//        int friendID = (int)[correctFriendDisguised objectForKey:@"id"];
//        [self startConnectionToGetProfilePicForFriendID:friendID];
//        NSMutableArray *friendChoices = [[NSMutableArray alloc] initWithObjects:correctFriendDisguised, nil];
//        
//        for (int i = 0; i < 4; i++) {
//            
//            //Getting random mutual
//            uint32_t rndIdx = arc4random_uniform([mutualsRaw count]);
//            while ([rndSet containsObject:@(rndIdx)]) {
//                rndIdx = arc4random_uniform([mutualsRaw count]);
//            }
//            [rndSet addObject:@(rndIdx)];
//            
//            //Adding to mutual to friend choices
//            NSMutableDictionary *randomFriend = [[NSMutableDictionary alloc] initWithDictionary:mutualsRaw[rndIdx]];
//            int friendID = (int)[randomFriend objectForKey:@"id"];
//            [self startConnectionToGetProfilePicForFriendID:friendID];
//            [friendChoices addObject:randomFriend];
//        }
//        _friendOptions = friendChoices;
//    }
//    [self didGetAllData];
//}
//
//
//- (void)startConnectionToGetProfilePicForFriendID:(int)inputID
//{
//    NSString *pictureGraphPath = [NSString stringWithFormat:@"%d/picture",
//                                       inputID];
//    NSLog(@"FB ID: %d", inputID);
//    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
//                                                  graphPath:pictureGraphPath];
//    FBRequestHandler handler = ^(FBRequestConnection *connection, id result, NSError *error) {
//        [self requestForProfilePicCompleted:connection
//                                    forFBID:inputID
//                                     result:result
//                                      error:error];
//    };
//    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
//    [connection addRequest:request
//         completionHandler:handler];
//    
//    [connection start];
//
//}
//
//- (void)requestForProfilePicCompleted:(FBRequestConnection *)connection
//                              forFBID:(int)inputID
//                               result:(id)result
//                               error:(NSError *)error
//{
//    if (error) {
//        NSLog(@"picture request failed");
//    } else {
//        NSDictionary *picData = [(NSDictionary *)result objectForKey:@"data"];
//        NSURL *imageURL = [NSURL URLWithString:(NSString *)[picData objectForKey:@"url"]];
//        NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
//        UIImage *image = [UIImage imageWithData:imageData];
//        [self incrementPulledPictureCountWithImage:image forID:inputID];
//    }
//}
//
//- (void)incrementPulledPictureCountWithImage:(UIImage *)image forID:(int)inputID;
//{
//    _pulledPicCount++;
//    [_tempImageStore setObject:image forKey:@(inputID)];
//    if (_pulledPicCount == 5) {
//        [self matchProfilePicsToIDs];
//    }
//}
//
//- (void)matchProfilePicsToIDs
//{
//    for (NSMutableDictionary *dic in _friendOptions) {
//        UIImage *image = [_tempImageStore objectForKey:[dic objectForKey:@"id"]];
//        [dic setObject:image forKey:@"image"];
//    }
//    [self didGetAllData];
//}

- (void)didGetAllData
{
    NSLog(@"%@", _currentStatus);
    NSLog(@"%@", _correctFriendDict);
    NSLog(@"%@", _friendOptions);
    GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController"
                                                                                  bundle:nil];
    [gameViewController setCurrentStatus:_currentStatus];
    [[gameViewController statusTextView] setText:_currentStatus];
    [gameViewController setCorrectFriendName:[_correctFriendDict objectForKey:@"name"]];
    [gameViewController setFriendOptions:_friendOptions];
    
    [self.navigationController pushViewController:gameViewController animated:YES];
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

