//
//  StaticTextView.m
//  WhoStat
//
//  Created by Dan Schlosser on 7/18/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "StaticTextView.h"

@implementation StaticTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}
- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end
