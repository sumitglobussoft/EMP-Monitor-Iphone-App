//
//  ChangePassword.h
//  EmployeeMonitoringSystem
//
//  Created by Globussoft 1 on 2/10/15.
//  Copyright (c) 2015 Globussoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ChangePassword : NSViewController<NSXMLParserDelegate>

@property (strong) IBOutlet NSSecureTextField *oldPassword;
@property (strong) IBOutlet NSSecureTextField *reEnterPassword;
@property (strong) IBOutlet NSSecureTextField *nwPassword;
@property (strong) IBOutlet NSButton *changePsdAction;
@property (strong) IBOutlet NSButton *Cancelbutton;
@property (strong) IBOutlet NSButton *backbutton;


-(IBAction)changePassword:(id)sender;
-(IBAction)CancelAction:(id)sender;
-(IBAction)backAction:(id)sender;
@end
