//
//  FBRequestController.h
//  WhoStat
//
//  Created by Aleks Kamko on 7/14/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBRequestControllerDelegate <NSObject>

- (void)didGetRoundData:(NSDictionary *)round;

@end

@interface FBRequestController : NSObject

@property (strong, nonatomic) id <FBRequestControllerDelegate> delegate;

+ (FBRequestController *)sharedController;
- (void)startScrapingFacebookData;

@end