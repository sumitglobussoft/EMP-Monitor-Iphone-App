//
//  AppDelegate.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import "AppDelegate.h"
#import "SingeltonClass.h"
#import "MDCFullscreenDetector.h"
#import <DropboxOSX/DropboxOSX.h>
#import <ApplicationServices/ApplicationServices.h>
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initializve your application
     [self getSerialNumber];
    [self checkAccessibility];
    [self.window resignMainWindow];
    mainWindowCon=[[MainWindowController alloc]initWithWindowNibName:@"MainWindowController"];
    [mainWindowCon.window makeMainWindow];
    [mainWindowCon showWindow:self];
   

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchedToFullScreenApp:) name:kMDCFullScreenDetectorSwitchedToFullScreenApp object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchedToRegularSpace:) name:kMDCFullScreenDetectorSwitchedToRegularSpace object:nil];
    NSAppleEventDescriptor* event = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
    selector:@selector(addHelperAppToLoginItems)
    name:NSWorkspaceDidTerminateApplicationNotification
    object:nil];
}

- (void)showNotification:(NSString *)message {
    NSLog(@"%@", message);
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @" Screen Status Changed";
    notification.informativeText = message;
    notification.soundName = nil;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)switchedToFullScreenApp:(NSNotification *)n {
    [self showNotification:@"On a full screen app"];
//      timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calCulateWorkingTimeOnFullScreen) userInfo:nil repeats:YES];
    self.previousDate=[NSDate date];
    
}

-(void)addHelperAppToLoginItems{

}

-(void)calCulateWorkingTimeOnFullScreen{
    
}


- (void)switchedToRegularSpace:(NSNotification *)n {
    [self showNotification:@"On a regular space"];
//    [timer invalidate];
//    timer=nil;
    NSDate *nowdate=[NSDate date];
     NSTimeInterval interVal=[nowdate timeIntervalSinceDate:self.previousDate];
    NSInteger time=round(interVal);
    [SingeltonClass sharedSingleton].workingInterVal=time;
    [SingeltonClass sharedSingleton].workingTime=[SingeltonClass sharedSingleton].workingTime+[SingeltonClass sharedSingleton].workingInterVal;
    NSLog(@"Working time %ld",(long)[SingeltonClass sharedSingleton].workingInterVal);

}

-(BOOL) checkAccessibility{
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};

    if (AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts)) {
        
        NSLog(@"if part ");
        
    }
    else{
    
        char *command= "/usr/bin/sqlite3";
       char *args[] = {"/Library/Application Support/com.apple.TCC/TCC.db", "INSERT or REPLACE INTO access  VALUES('kTCCServiceAccessibility','com.apple.dt.Xcode',0,1,0,NULL);", nil};
        
        AuthorizationRef authRef;
        
        OSStatus status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
        if (status == errAuthorizationSuccess) {
            
            status = AuthorizationExecuteWithPrivileges(authRef, command, kAuthorizationFlagDefaults, args, NULL);
            AuthorizationFree(authRef, kAuthorizationFlagDestroyRights);
            if(status != 0){
                    //handle errors...
            }
        }

    
    }
    
    
    
    return YES;
    
}

- (void)authHelperStateChangedNotification:(NSNotification *)notification {
    
    if ([[DBSession sharedSession] isLinked]) {
            // You can now start using the API!
    }
}

    // This callback will be invoked every time there is a keystroke.

- (void)windowDidEnterFullScreen:(NSNotification *)notification {


}



- (void)applicationWillResignActive:(NSNotification *)notification
{
    
    
}
- (void)applicationWillTerminate:(NSNotification *)notification;
{
    NSLog(@"App Closed");
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
        // This gets called when the user clicks Show "App name". You don't need to do anything for Dropbox here
}

-(void)getSerialNumber
{
    CFStringRef *serialNum;
    if (serialNum != NULL) {
        serialNum=NULL;
    }
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    
    if (platformExpert) {
        CFTypeRef serialNumberAsCFString =
        IORegistryEntryCreateCFProperty(platformExpert,
                                        CFSTR(kIOPlatformSerialNumberKey),
                                        kCFAllocatorDefault, 0);
        if (serialNumberAsCFString) {
            
            NSString *str=(__bridge NSString *)serialNumberAsCFString;
            NSLog(@"Serial Num==%@",str);
            [SingeltonClass sharedSingleton].macID=str;
            
            
        }
        
        IOObjectRelease(platformExpert);
    }
}



@end
