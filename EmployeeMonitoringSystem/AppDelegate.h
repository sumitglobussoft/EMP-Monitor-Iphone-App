//
//  AppDelegate.h
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import <DropboxOSX/DropboxOSX.h>
#import "MDCFullScreenDetector.h"
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate>
{
    
    MainWindowController *mainWindowCon;
    NSTimer *timer;

}
@property (nonatomic,strong) NSDate  *previousDate;
@property (assign) IBOutlet NSWindow *window;
- (void)showNotification:(NSString *)message;
- (void)switchedToFullScreenApp:(NSNotification *)n;
- (void)switchedToRegularSpace:(NSNotification *)n;
@end
