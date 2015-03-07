//
//  LogInViewController.h
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NextPageViewController.h"
#import <CommonCrypto/CommonCryptor.h>
#import <DropboxOSX/DropboxOSX.h>

@interface LogInViewController : NSViewController<NSXMLParserDelegate,DBRestClientDelegate>
{
    NSButton *logInBtn;
    NextPageViewController *tablePage;
    CGDirectDisplayID *displays;
    NSInteger time;
    NSTimer *timer;
    NSImage *storeImg;
    NSString *email;
    NSString *acessToken;
    NSMutableData *logInData,*insertData;
    NSMutableString *currentName;
    NSMutableArray *imageArray;
    NSInteger indexNumber;
    NSString *wsAccessToken;
    BOOL isNetworkAvilable;
    BOOL isDropBusy;
  
}
@property (nonatomic, strong) NSXMLParser  * forgetXmlParser;
@property (nonatomic, strong) NSXMLParser  * loginXmlParser;
@property (nonatomic, strong) NSXMLParser  * rememberMeXmlParser;
@property (nonatomic, strong) NSXMLParser  * insertXmlParser;
@property (nonatomic, strong) DBRestClient *restClient;
@property (strong) IBOutlet NSTextField *txtFEmail;
@property (strong) IBOutlet NSSecureTextField *txtFPassword;
@property (strong) IBOutlet NSButton *remembermeBtn;
@property (strong) IBOutlet NSButton *logInButton;
@property (strong) IBOutlet NSView *logInView;
@property (strong) IBOutlet NSView *WhiteView;
@property (weak) IBOutlet NSView *customImgView;

- (IBAction)rememberMeAction:(id)sender;
@end
