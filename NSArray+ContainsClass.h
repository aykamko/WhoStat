//
//  NSArray+ContainsClass.h
//  WhoStat
//
//  Created by Aleks Kamko on 7/14/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ContainsClass)

- (BOOL)containsClass:(__unsafe_unretained Class)inputClass;

@end
