//
//  OrangeButton.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/17/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import "OrangeButton.h"

@implementation OrangeButton

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
    [[NSColor orangeColor]setFill];
    NSRectFill(dirtyRect);
    // Drawing code here.
}

@end
