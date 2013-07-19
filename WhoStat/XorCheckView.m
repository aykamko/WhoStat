//
//  XorCheckView.m
//  WhoStat
//
//  Created by Aleks Kamko on 7/19/13.
//  Copyright (c) 2013 Dan Schlosser. All rights reserved.
//

#import "XorCheckView.h"

@interface XorCheckView ()
@property (nonatomic) NSInteger *xOrCheck;
@end
@implementation XorCheckView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setXOrCheck:(NSInteger *)xOrCheck
{
    _xOrCheck = xOrCheck;
    [self setNeedsDisplay];
}

- (void)drawX
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextSetLineWidth(context, 20.0);
    
    CGPoint startPoint1 = CGPointMake(10, 10);
    CGPoint endPoint1 = CGPointMake(self.bounds.size.width - 10,
                                    self.bounds.size.height - 10);
    CGPoint startPoint2 = CGPointMake(self.bounds.size.width - 10,
                                      10);
    CGPoint endPoint2 = CGPointMake(10,
                                    self.bounds.size.height - 10);
    
    CGContextMoveToPoint(context, startPoint1.x, startPoint1.y);
    CGContextAddLineToPoint(context, endPoint1.x, endPoint1.y);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, startPoint2.x, startPoint2.y);
    CGContextAddLineToPoint(context, endPoint2.x, endPoint2.y);
    CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect
{
    [self drawRect:rect];
    if (_xOrCheck == 0) {
        [self drawX];
    } else {
//        [self drawCheck];
    }
}

@end
