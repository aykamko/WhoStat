//
//  FBRequestController.h
//  WhoStat
//
//  Created by Aleks Kamko on 7/14/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBRequestController : NSObject

@property (nonatomic, readonly) BOOL isScraping;

+ (FBRequestController *)sharedController;
- (void)startScrapingFacebookDataWithCompletionBlock:(void (^)(NSDictionary *round))completion;

@end