//
//  FBRequestController.m
//  WhoStat
//
//  Created by Aleks Kamko on 7/14/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "FBRequestController.h"
#import "WhoStatAppDelegate.h"
#import "NSMutableArray+Shuffling.h"
#import "GameRoundQueue.h"

@implementation FBRequestController

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedController];
}

+ (FBRequestController *)sharedController
{
    static FBRequestController *sharedController = nil;
    if (!sharedController) {
        sharedController = [[super allocWithZone:nil] init];
    }
    return sharedController;
}

- (void)startScrapingFacebookData
{
    if (FBSession.activeSession.isOpen) {
        NSMutableDictionary *round = [[NSMutableDictionary alloc] init];
        _isScraping = YES;
        [self startConnectionToScrapeStatusIntoRound:round];
    } else {
        FBSessionStateHandler handler =
        ^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                _isScraping = NO;
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
                NSMutableDictionary *round = [[NSMutableDictionary alloc] init];
                _isScraping = YES;
                [self startConnectionToScrapeStatusIntoRound:round];
            }
        };
        dispatch_async(dispatch_get_main_queue(), ^{
            [FBSession openActiveSessionWithReadPermissions:@[@"read_stream"]
                                               allowLoginUI:YES
                                          completionHandler:handler];
        });
    }
}

- (void)startConnectionToScrapeStatusIntoRound:(NSMutableDictionary *)round
{
    
    NSString *query =
    @"SELECT status_id, message, uid FROM status WHERE uid IN ("
        @"SELECT uid2 FROM friend WHERE uid1 = me()"
    @") order by rand() limit 1";
    
    NSDictionary *queryParam = @{ @"q": query };
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestForStatusCompleted:connection
                                  round:round
                                 result:result
                                  error:error];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:queryParam
                                     HTTPMethod:@"GET"
                              completionHandler:handler];
    });
}

- (void)requestForStatusCompleted:(FBRequestConnection *)connection
                            round:(NSMutableDictionary *)round
                           result:(id)result
                            error:(NSError *)error
{
    if (error) {
        _isScraping = NO;
        NSLog(@"status request error");
        return;
    } else {
        NSDictionary *statusDict =
        [(NSDictionary *)result valueForKey:@"data"][0];
        round[@"status"] = statusDict[@"message"];
        round[@"correctID"] = statusDict[@"uid"];
        
        [self startConnectionToScrapeFriendDataIntoRound:round];
    }
    
}

- (void)startConnectionToScrapeFriendDataIntoRound:(NSMutableDictionary *)round
{
    // Query building
    NSString *query =
    [NSString stringWithFormat:
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
       //                       _currentStatusDict[@"uid"],
       round[@"correctID"]];

    
    NSDictionary *queryParam = @{ @"q": query };
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestForFriendDataCompleted:connection
                                      round:round
                                     result:result
                                      error:error];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:queryParam
                                     HTTPMethod:@"GET"
                              completionHandler:handler];
    });
}

- (void)requestForFriendDataCompleted:(FBRequestConnection *)connection
                                round:(NSMutableDictionary *)round
                               result:(id)result
                                error:(NSError *)error
{
    if (error) {
        _isScraping = NO;
        NSLog(@"friend data request failed");
        return;
    } else {
        NSMutableArray *friendOptions = [[NSMutableArray alloc] init];
        NSArray *rawData = result[@"data"];
        NSMutableDictionary *correctFriendDict =
            rawData[0][@"fql_result_set"][0];
        NSArray *randFriendArray =
            rawData[1][@"fql_result_set"];
        
        //        NSArray *randMutualFriendArray =
        //            rawData[1][@"fql_result_set"];

        
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
        round[@"correctName"] = correctFriendDict[@"name"];
        round[@"correctPic"] = correctFriendDict[@"pic_big"];
        
        [friendOptions addObject:correctFriendDict];
        
        /* Getting mutual friends is hard. :( */
        
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
        
        size_t count = 4;
        dispatch_queue_t queue =
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_apply(count, queue, ^(size_t i) {
            NSMutableDictionary *userDict = randFriendArray[i];
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
            [friendOptions addObject:userDict];
        });
                       
//        for (NSMutableDictionary *userDict in randFriendArray) {
//            NSURL *squareImageURL = [NSURL
//                                     URLWithString:userDict[@"pic_square"]];
//            NSData *squareImageData = [NSData
//                                       dataWithContentsOfURL:squareImageURL];
//            UIImage *squareImage = [UIImage imageWithData:squareImageData];
//            
//            NSURL *bigImageURL = [NSURL
//                                  URLWithString:userDict[@"pic_big"]];
//            NSData *bigImageData = [NSData
//                                    dataWithContentsOfURL:bigImageURL];
//            UIImage *bigImage = [UIImage imageWithData:bigImageData];
//            
//            userDict[@"pic_square"] = squareImage;
//            userDict[@"pic_big"] = bigImage;
//            [friendOptions addObject:userDict];
//        }
                       
        // Shuffles the array
        [friendOptions shuffle];
        
        round[@"friendOptions"] = friendOptions;
        NSDictionary *staticRound = [[NSDictionary alloc]
                                     initWithDictionary:round];
        _isScraping = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didGetRoundData:staticRound];
        });
        NSLog(@"rounds: %d", [[GameRoundQueue sharedQueue] queueLength]);
    }
}

@end
