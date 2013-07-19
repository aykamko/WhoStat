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

#define WSLog(...) do{}while(0);//NSLog(__VA_ARGS__)

@interface FBRequestController ()
@property (nonatomic, strong) void (^completionBlock)(NSDictionary *round);
@end

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

- (void)startScrapingFacebookDataWithCompletionBlock:(void (^)(NSDictionary *round))completion
{
    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^(void){
        
    [self setCompletionBlock:completion];
        
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
                WSLog(@"successful login!");
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
        
    });
}

- (void)startConnectionToScrapeStatusIntoRound:(NSMutableDictionary *)round
{
    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^(void){

    
    NSString *query =
    @"SELECT message, uid FROM status WHERE uid IN ("
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
        
    });
}

- (void)requestForStatusCompleted:(FBRequestConnection *)connection
                            round:(NSMutableDictionary *)round
                           result:(id)result
                            error:(NSError *)error
{
    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^(void){
    
    if (error) {
        _isScraping = NO;
        WSLog(@"status request error");
        WSLog(@"%@", error.localizedDescription);
        return;
    } else {
        NSDictionary *statusDict =
        [(NSDictionary *)result valueForKey:@"data"][0];
        round[@"status"] = statusDict[@"message"];
        round[@"correctID"] = statusDict[@"uid"];
        
        [self startConnectionToScrapeFriendDataIntoRound:round];
    }
        
    });
}

- (void)startConnectionToScrapeFriendDataIntoRound:(NSMutableDictionary *)round
{
    
    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^(void){
        
    NSString *graphPath = [NSString stringWithFormat:
        @"me?fields=friends.fields(name,picture.width(200).height(200)),"
        @"mutualfriends.user(%@).fields(name,picture.width(200).height(200))",
                           round[@"correctID"]];

    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestForFriendDataCompleted:connection
                                      round:round
                                     result:result
                                      error:error];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [FBRequestConnection startWithGraphPath:graphPath
                              completionHandler:handler];
    });
        
    });
}

- (void)requestForFriendDataCompleted:(FBRequestConnection *)connection
                                round:(NSMutableDictionary *)round
                               result:(id)result
                                error:(NSError *)error
{
    
    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^(void){
        
    if (error) {
        _isScraping = NO;
        WSLog(@"friend data request failed");
        return;
    } else {
        NSArray *friends = ((NSDictionary *) result)[@"friends"][@"data"];
        NSArray *mutuals = ((NSDictionary *) result)[@"mutualfriends"][@"data"];
        NSMutableArray *friendOptions = [[NSMutableArray alloc] init];
        
        int maxIndex = 4;
        if ([mutuals count] < 4)
            maxIndex = [mutuals count];
        
        WSLog(@"count: %d", maxIndex);
        NSMutableSet *usedIndexes = [[NSMutableSet alloc] init];
        for (int i = 0; i < maxIndex; i++)
        {
            u_int32_t randIndex;
            do {
                randIndex = arc4random_uniform([mutuals count]);
            } while ([usedIndexes containsObject:@(randIndex)]);
            NSMutableDictionary *userDict = mutuals[randIndex];
            [usedIndexes addObject:@(randIndex)];
            
            NSURL *imageURL =
                [NSURL URLWithString:userDict[@"picture"][@"data"][@"url"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            [userDict removeObjectForKey:@"picture"];
            userDict[@"image"] = image;

            [friendOptions addObject:userDict];
        }
        
        maxIndex = 4 - maxIndex;
        WSLog(@"left: %d", maxIndex);
        for (int i = 0; i < maxIndex; i++)
        {
            u_int32_t randIndex;
            do {
                randIndex = arc4random_uniform([friends count]);
            } while ([usedIndexes containsObject:@(randIndex)]);
            NSMutableDictionary *userDict = friends[randIndex];
            [usedIndexes addObject:@(randIndex)];
            
            NSURL *imageURL =
                [NSURL URLWithString:userDict[@"picture"][@"data"][@"url"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            [userDict removeObjectForKey:@"picture"];
            userDict[@"image"] = image;

            [friendOptions addObject:userDict];
        }
        WSLog(@"length: %d", [friendOptions count]);
        
        round[@"friendOptions"] = friendOptions;
        [self startConnectionToScrapeCorrectFriendDataIntoRound:round];
//        NSDictionary *staticRound = [[NSDictionary alloc]
//                                     initWithDictionary:round];
//        _isScraping = NO;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate didGetRoundData:staticRound];
//        });
//        WSLog(@"rounds: %d", [[GameRoundQueue sharedQueue] queueLength]);
    }
    
    });
}

- (void)startConnectionToScrapeCorrectFriendDataIntoRound:(NSMutableDictionary *)round
{
    
    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^(void){
        
    NSString *graphPath = [NSString stringWithFormat:
        @"%@?fields=name,picture.width(200).height(200)",
                           round[@"correctID"]];

    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestForCorrectFriendDataCompleted:connection
                                             round:round
                                            result:result
                                             error:error];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [FBRequestConnection startWithGraphPath:graphPath
                              completionHandler:handler];
    });
        
    });
}

- (void)requestForCorrectFriendDataCompleted:(FBRequestConnection *)connection
                                       round:(NSMutableDictionary *)round
                                      result:(id)result
                                       error:(NSError *)error
{
    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^(void){
        
        round[@"correctName"] = result[@"name"];
    NSURL *imageURL = [NSURL
                  URLWithString:result[@"picture"][@"data"][@"url"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    [result removeObjectForKey:@"picture"];
    result[@"image"] = image;
    round[@"correctPic"] = image;
    
    NSMutableArray *roundArray = round[@"friendOptions"];
    [roundArray addObject:result];
    [roundArray shuffle];
    
    NSNumber *idx = [[NSNumber alloc]
                     initWithUnsignedInteger:[roundArray indexOfObject:result]];
    round[@"correctFriendIndex"] = idx;
    round[@"friendOptions"] = roundArray;
    
    _isScraping = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self completionBlock](round);
    });
        
    });
    
}

@end
