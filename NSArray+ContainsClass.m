//
//  NSArray+ContainsClass.m
//  WhoStat
//
//  Created by Aleks Kamko on 7/14/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "NSArray+ContainsClass.h"

@implementation NSArray (ContainsClass)

- (BOOL)containsClass:(__unsafe_unretained Class)inputClass
{
    __block BOOL contains = NO;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[inputClass class]]) {
            contains = YES;
            return;
        }
    }];
    return contains;
}

@end
