//
//  SettingViewController.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/15/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import "SettingViewController.h"
#import "SingeltonClass.h"
#import "NextPageViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
        
         rememberMe=1;
         AutoRunApp=1;
         showBusy=1;
         notificationOn=1;
        notificationtime=5;
    }
    return self;
}

- (IBAction)okBtnAction:(id)sender {
    
    
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
                          "<NotificationTime>%d</NotificationTime>\n"
                          "<Task>%@</Task>\n"
                          "<AccessToken>%@</AccessToken>\n"
                          "</UpdateUserSettings>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",[SingeltonClass sharedSingleton].emailId,[self.txtfName stringValue],(long)rememberMe,(long)AutoRunApp,(long)showBusy,(long)notificationOn,[[self.notificationTime stringValue] intValue],[self.txtFMsg stringValue],[SingeltonClass sharedSingleton].token ];
    
    NSString *strInsertUrl=[NSString stringWithFormat:@"%@op=UpdateUserSettings",WebLink];
    NSURL *insertUrl=[NSURL URLWithString:strInsertUrl];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:insertUrl];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMesage length]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/UpdateUserSettings" forHTTPHeaderField:@"SOAPAction"];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMesage dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection connectionWithRequest:request delegate:self];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSData* xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSXMLParser  * xmlParser = [[NSXMLParser alloc] initWithData:[xmlData copy]];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
    NSLog(@"String Value1==%@",xmlString);

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI  qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
        // SUPPOSE TO READ ALL XML FILE AND FIND ALL "name" ELEMENTS
    if ([elementName isEqualToString:@"UpdateUserSettingsResult"]) {
        
//        currentName = [[NSMutableString alloc] init];
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    NSLog(@"%@",string);
    
//    [currentName appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

    if ([string isEqualToString:@"\"true\""]) {
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        [userDefault setObject:[self.txtfName stringValue] forKey:@"DisplayName"];
        [userDefault setInteger:rememberMe forKey:@"RememberMe"];
        [userDefault setInteger:notificationOn forKey:@"NotificationOn"];
        [userDefault setInteger:notificationtime forKey:@"NotificationTime"];
        [userDefault setInteger:showBusy forKey:@"ShowBusyWhenFullScreenMode"];
        [userDefault setInteger:AutoRunApp   forKey:@"AutoRunApp"];

        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        alert.delegate=self;
        [alert setMessageText:@"Setting Changed"];
        [alert setInformativeText:@"User setting successfuly Changed."];
        [alert setAlertStyle:NSWarningAlertStyle];
//         [alert runModal];
        [alert beginSheetModalForWindow:[[self view] window] completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSAlertFirstButtonReturn)
            {
                self.settingView.hidden=YES;
          NextPageViewController     * tablePage=[[NextPageViewController alloc]initWithNibName:@"NextPageViewController" bundle:nil];
                [self.view addSubview:tablePage.view];
            }
            else
            {
//                confirmFlag = NO;
            }
                //Rest of your code goes in here.
        }];

               
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        alert.delegate=self;
        [alert setMessageText:@"Setting updation failed"];
        [alert setInformativeText:@"User setting updating failed."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    
    }
         
         }
-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   NSString * str = [currentName stringByReplacingOccurrencesOfString:@"<br />" withString:@""];

    
    if ([elementName isEqualToString:@"UpdateUserSettingsResult"]) {
        NSLog(@"%@",str);
    }

}

- (IBAction)cancelBtnAction:(NSButton *)sender {
    
    self.settingView.hidden=YES;
    NextPageViewController     * tablePage=[[NextPageViewController alloc]initWithNibName:@"NextPageViewController" bundle:nil];
    [self.view addSubview:tablePage.view];

}

- (IBAction)notificationAction:(NSButton *)sender{
    notificationOn=sender.state;
}
- (IBAction)showBusyAction:(NSButton *)sender{
    NSLog(@"show busy Action %ld",(long)sender.state );
    showBusy=sender.state;

}
- (IBAction)autoRunAction:(NSButton *)sender{
    AutoRunApp=sender.state;


}

@end
