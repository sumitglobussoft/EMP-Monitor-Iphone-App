//
//  NextPageViewController.h
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WhiteView.h"
#import "SettingViewController.h"
#import "ChangePassword.h"
#import <sqlite3.h>

@interface NextPageViewController : NSViewController<NSUserNotificationCenterDelegate,NSTextFieldDelegate,NSComboBoxDelegate>
{
    SettingViewController *settings;
    ChangePassword *changePswdView;
    NSDate *signOutDate;
    sqlite3 *databaseMoz,*databaseChrome;
    NSMutableArray *arrMozHistory,*arrChromeHistory,*arrSafari;
   // NSTimer *workingTimer,*nonWorkingTimer,*mouseTimer;
    NSDate *prevDate,*initDate;
   
    NSMutableData *updateData;
    NSMutableURLRequest *request;
    NSMutableString *strBrowserHistroy,*strKeyStrokes;

    NSMutableString *currentActiveApp;
    NSRunningApplication *oldApp;
 NSTimer *timer;

}

@property (strong) IBOutlet WhiteView *popUpView;
@property (strong) IBOutlet NSView *pageView;
@property (nonatomic,strong) NSDate *logInDate;
@property (nonatomic,strong) NSDate *previousDate;
@property (nonatomic,strong)IBOutlet NSTextField *inputTaskField;
@property (strong) IBOutlet NSTextField *workingHrs;
@property (strong) IBOutlet NSTextField *nonWorkingHrs;
@property (strong) IBOutlet NSComboBox *stateBox;
@property (strong) IBOutlet NSView *orangeView;
@property (nonatomic,strong) IBOutlet NSView *changePasswordView;

- (IBAction)cancelBtnAction:(id)sender;
- (IBAction)signOutBtnAction:(id)sender;


@end
