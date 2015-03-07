//
//  WhiteView.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/15/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import "WhiteView.h"
#import "SingeltonClass.h"

@implementation WhiteView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSRect rect=NSRectFromCGRect(CGRectMake(0, 0, 900, 200));
   
    
   CGContextRef context=(CGContextRef)[NSGraphicsContext currentContext].graphicsPort;
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context,dirtyRect);

    if ([SingeltonClass sharedSingleton].checkView) {
        CGContextRef context1=(CGContextRef)[NSGraphicsContext currentContext].graphicsPort;
        CGContextSetRGBFillColor(context1, (CGFloat)77/255,(CGFloat)33/255, (CGFloat)3/255, 1.0);
        CGContextFillRect(context1, rect);
    }

    
    

    
    // Drawing code here.
}

@end
