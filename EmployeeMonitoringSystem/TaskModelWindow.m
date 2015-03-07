//
//  TaskModelWindow.m
//  EmployeeMonitoringSystem
//
//  Created by Globussoft 1 on 3/3/15.
//  Copyright (c) 2015 Globussoft. All rights reserved.
//

#import "TaskModelWindow.h"
#import "SingeltonClass.h"

@interface TaskModelWindow ()

@end

@implementation TaskModelWindow
@synthesize statusStr;
- (void)viewDidLoad {
    [super viewDidLoad];
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0.227,0.251,0.337,0.8);
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[[NSColor colorWithCalibratedRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] CGColor]];
    // Do view setup here.
}
-(IBAction)enterTaskAction:(id)sender{

    if([[self.taskTextView string]isEqualToString:@""])
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Please update the task"];
            [alert setInformativeText:@"please enter valid and readable task"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            return;
        }
        
  NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
  NSString *displayName= [userDefault objectForKey:@"DisplayName"];
  NSInteger rememberMe =  [userDefault integerForKey:@"RememberMe"];
  NSInteger notificationOn= [userDefault integerForKey:@"NotificationOn"];
  NSInteger notificationTime= [userDefault integerForKey:@"NotificationTime"];
  NSInteger showBusy= [userDefault integerForKey:@"ShowBusyWhenFullScreenMode"];
  NSInteger autoRunApp= [userDefault integerForKey:@"AutoRunApp"];
    NSString *task=[NSString stringWithFormat:@" %@ :- %@",self.statusStr,[self.taskTextView string]];
    
    
    NSString *soapMesage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<UpdateUserSettings  xmlns=\"http://tempuri.org/\">\n"
                          "<EmailId>%@</EmailId>\n"
                          "<DisplayName>%@</DisplayName>\n"
                          "<RememberMe>%ld</RememberMe>\n"
                          "<AutoRunApp>%ld</AutoRunApp>\n"
                          "<ShowBusyWhenFullScreenMode>%ld</ShowBusyWhenFullScreenMode>\n"
                          "<Notification>%ld</Notification>\n"
                          "<NotificationTime>%ld</NotificationTime>\n"
                          "<Task>%@</Task>\n"
                          "<AccessToken>%@</AccessToken>\n"
                          "</UpdateUserSettings>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",[SingeltonClass sharedSingleton].emailId,displayName,(long)rememberMe,(long)autoRunApp,(long)showBusy,(long)notificationOn,(long)notificationTime,task,[SingeltonClass sharedSingleton].token ];
    
    NSString *strInsertUrl=[NSString stringWithFormat:@"%@op=UpdateUserSettings",WebLink];
    NSURL *insertUrl=[NSURL URLWithString:strInsertUrl];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:insertUrl];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMesage length]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/UpdateUserSettings" forHTTPHeaderField:@"SOAPAction"];
    [request addValue:@"api.empmonitor.com" forHTTPHeaderField:@"Host"];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMesage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSData* xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSXMLParser  * xmlParser = [[NSXMLParser alloc] initWithData:[xmlData copy]];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
//    NSLog(@"String Value1==%@",xmlStrin
    
}
-(IBAction)cancelAction:(id)sender{

    [self dismissController:nil];
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([string isEqualToString:@"\"true\""]) {
        [self dismissController:nil];
    }else{
    
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Task not updated"];
        [alert setInformativeText:@"Please try again ."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"UpdateUserSettingsResult"]) {
        
    }
}

@end
