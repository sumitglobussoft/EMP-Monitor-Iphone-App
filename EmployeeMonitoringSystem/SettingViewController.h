//
//  SettingViewController.h
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/15/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SettingViewController : NSViewController<NSXMLParserDelegate,NSAlertDelegate>
{
NSInteger rememberMe;
NSInteger AutoRunApp;
NSInteger showBusy;
NSInteger notificationOn;
NSInteger notificationtime;
 NSString *updateTask;
    NSMutableString *  currentName;
   

}
@property (strong) IBOutlet NSView *settingView;

@property (strong) IBOutlet NSTextField *txtfName;
@property (strong) IBOutlet NSTextField *txtFMsg;
@property (strong) IBOutlet NSTextField *notificationTime;
@property (strong) IBOutlet NSButton *AutorunApp;
@property (strong) IBOutlet NSButton *Notification;
@property (strong) IBOutlet NSButton *ShowBusy;
- (IBAction)okBtnAction:(id)sender;
- (IBAction)cancelBtnAction:(id)sender;
- (IBAction)notificationAction:(id)sender;
- (IBAction)showBusyAction:(id)sender;
- (IBAction)autoRunAction:(id)sender;


@end
