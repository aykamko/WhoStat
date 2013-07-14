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
#import "NSMutableArray+Shuffling.h"

@interface TitleViewController ()

@property (strong, nonatomic) NSDictionary *currentStatusDict;

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
        FBSessionStateHandler handler =
        ^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:error.localizedDescription
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
                return;
            } else if (session.isOpen) {
                NSLog(@"successful login!");
                [self startConnectionToScrapeStatus];
            }
        };
        [FBSession openActiveSessionWithReadPermissions:@[@"read_stream"]
                                           allowLoginUI:YES
                                      completionHandler:handler];
    }
    
}

- (void)startConnectionToScrapeStatus
{
    
    NSString *query =
    @"SELECT status_id, message, uid FROM status WHERE uid IN ("
        @"SELECT uid2 FROM friend WHERE uid1 = me()"
    @") order by rand() limit 1";
    
    //NSLog(@"%@", query);
    NSDictionary *queryParam = @{ @"q": query };
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestForStatusCompleted:connection
                                 result:result
                                  error:error];
    };
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:handler];
}

- (void)requestForStatusCompleted:(FBRequestConnection *)connection
                           result:(id)result
                            error:(NSError *)error
{
    if (error) {
        NSLog(@"status request error");
    } else {
        NSDictionary *statusDict =
            [(NSDictionary *)result valueForKey:@"data"][0];
        _currentStatusDict = statusDict;
        _currentStatus = _currentStatusDict[@"message"];

        [self startConnectionToScrapeFriendData];
    }
    
}

- (void)startConnectionToScrapeFriendData
{
    // Query building
    NSString *query = [NSString stringWithFormat:
    @"{"
    @"\"correctFriendData\":"
        @"\"SELECT uid, name, pic_big, pic_square FROM user WHERE uid = %@\", "
//    @"\"randMutualFriendsData\":"
//        @"\"SELECT uid, name, pic_big, pic_square FROM user WHERE uid IN ("
//            @"SELECT uid1 FROM friend WHERE uid1 IN ("
//                @"SELECT uid2 FROM friend WHERE uid1 = %@) "
//            @"AND uid2 IN ("
//                @"SELECT uid2 FROM friend WHERE uid1 = me()) "
//            @"ORDER BY rand() LIMIT 4)"
//        @"\", "
    @"\"randFriendsData\":"
        @"\"SELECT uid, name, pic_big, pic_square FROM user WHERE uid IN "
            @"(SELECT uid2 FROM friend WHERE uid1 = me()) "
        @"ORDER BY rand() LIMIT 4\""
    @"}",
                       //_currentStatusDict[@"uid"],
                       _currentStatusDict[@"uid"]];

    NSDictionary *queryParam = @{ @"q": query };
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
        //NSLog(@"%@", error);
        NSLog(@"friend data request failed");
    } else {
        _friendOptions = [[NSMutableArray alloc] init];
        NSArray *rawData = result[@"data"];
        NSMutableDictionary *correctFriendDict =
            rawData[0][@"fql_result_set"][0];
        //NSArray *randMutualFriendArray =
        //    rawData[1][@"fql_result_set"];
        NSArray *randFriendArray =
            rawData[1][@"fql_result_set"];
        
        NSURL *squareImageURL = [NSURL
                           URLWithString:correctFriendDict[@"pic_square"]];
        NSData *squareImageData = [NSData
                                   dataWithContentsOfURL:squareImageURL];
        UIImage *squareImage = [UIImage imageWithData:squareImageData];
        NSURL *bigImageURL = [NSURL
                              URLWithString:correctFriendDict[@"pic_big"]];
        NSData *bigImageData = [NSData dataWithContentsOfURL:bigImageURL];
        UIImage *bigImage = [UIImage imageWithData:bigImageData];
        correctFriendDict[@"pic_square"] = squareImage;
        correctFriendDict[@"pic_big"] = bigImage;
        
        [_friendOptions addObject:correctFriendDict];
        
//        for (NSMutableDictionary *userDict in randMutualFriendArray) {
//            NSURL *squareImageURL = [NSURL
//                                     URLWithString:userDict[@"pic_square"]];
//            NSData *squareImageData = [NSData
//                                       dataWithContentsOfURL:squareImageURL];
//            UIImage *squareImage = [UIImage imageWithData:squareImageData];
//            NSURL *bigImageURL = [NSURL
//                                  URLWithString:userDict[@"pic_big"]];
//            NSData *bigImageData = [NSData dataWithContentsOfURL:bigImageURL];
//            UIImage *bigImage = [UIImage imageWithData:bigImageData];
//            userDict[@"pic_square"] = squareImage;
//            userDict[@"pic_big"] = bigImage;
//            
//            [_friendOptions addObject:userDict];
//        }
//        
//        if ([_friendOptions count] < 5) {
//            int maxIndex = 5 - [_friendOptions count]; }
        
        for (NSMutableDictionary *userDict in randFriendArray) {
            NSURL *squareImageURL = [NSURL
                                     URLWithString:userDict[@"pic_square"]];
            NSData *squareImageData = [NSData
                                       dataWithContentsOfURL:squareImageURL];
            UIImage *squareImage = [UIImage imageWithData:squareImageData];
            NSURL *bigImageURL = [NSURL
                                  URLWithString:userDict[@"pic_big"]];
            NSData *bigImageData = [NSData
                                    dataWithContentsOfURL:bigImageURL];
            UIImage *bigImage = [UIImage imageWithData:bigImageData];
            userDict[@"pic_square"] = squareImage;
            userDict[@"pic_big"] = bigImage;
            
            [_friendOptions addObject:userDict];
        }
        // Shuffle's the array
        [_friendOptions shuffle];
        [self didGetAllData];
    }
}

- (void)didGetAllData
{
    NSLog(@"%@", _currentStatus);
    NSLog(@"%@", _correctFriendDict);
    NSLog(@"%@", _friendOptions);
    GameViewController *gameViewController =
        [[GameViewController alloc]
         initWithNibName:@"GameViewController"
         bundle:nil];
    [gameViewController setCurrentStatus:_currentStatus];
    [[gameViewController statusTextView] setText:_currentStatus];
    [gameViewController setCorrectFriendName:[_correctFriendDict
                                              objectForKey:@"name"]];
    [gameViewController setFriendOptions:_friendOptions];
    
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

