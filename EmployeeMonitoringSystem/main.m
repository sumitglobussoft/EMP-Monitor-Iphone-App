//
//  main.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[])
{
    AppDelegate *delegate = [[AppDelegate alloc] init];
    NSApplication * application = [NSApplication sharedApplication];
    [application setDelegate:delegate];
    [NSApp run];
    return NSApplicationMain(argc, argv);
}
