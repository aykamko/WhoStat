//
//  GameRoundQueue.m
//  WhoStat
//
//  Created by Aleks Kamko on 7/14/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "GameRoundQueue.h"

@interface GameRoundQueue ()

@property NSMutableArray *queue;

@end

@implementation GameRoundQueue

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedQueue];
}

+ (GameRoundQueue *)sharedQueue
{
    static GameRoundQueue *sharedQueue = nil;
    if (!sharedQueue) {
        sharedQueue = [[super allocWithZone:nil] init];
    }
    return sharedQueue;
}

- (NSDictionary *)popRound
{
    NSDictionary *pop = [_queue firstObject];
    if (pop != nil) {
       [_queue removeObjectAtIndex:0];
    }
    return pop;
}

- (void)pushRound:(NSDictionary *)round
{
    [_queue addObject:round];
}

- (NSInteger)queueLength
{
    return (NSInteger)[_queue count];
}

@end
