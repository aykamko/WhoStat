//
//  GameRoundQueue.h
//  WhoStat
//
//  Created by Aleks Kamko on 7/14/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameRoundQueue : NSObject

+ (GameRoundQueue *)sharedQueue;

- (NSInteger)queueLength;
- (NSDictionary *)popRound;
- (void)pushRound:(NSDictionary *)round;

@end