//
//  TaskModelWindow.h
//  EmployeeMonitoringSystem
//
//  Created by Globussoft 1 on 3/3/15.
//  Copyright (c) 2015 Globussoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TaskModelWindow : NSViewController<NSTextViewDelegate,NSXMLParserDelegate>

@property(nonatomic,strong) IBOutlet NSTextView *taskTextView;
@property(nonatomic,strong)NSString *statusStr;

@property (strong) IBOutlet NSButton *enterTaskButton;
@property (strong) IBOutlet NSButton *cancelbutton;
-(IBAction)enterTaskAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
@end
