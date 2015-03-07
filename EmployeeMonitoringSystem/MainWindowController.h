//
//  MainWindowController.h
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogInViewController.h"
#import "NextPageViewController.h"
@interface MainWindowController : NSWindowController<NSWindowDelegate,DBRestClientDelegate>
{
     LogInViewController *logInViewCon;
     NSString *wsAccessToken;
     NSString *email;
     NSString *acessToken;
      NSTimer *timer;
      NSImage *storeImg;
     CGDirectDisplayID *displays;
     NextPageViewController *tablePage;
}
@property (strong) IBOutlet NSView *mainView;
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) NSXMLParser  * insertXmlParser;
@end
