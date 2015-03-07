//
//  ChangePassword.m
//  EmployeeMonitoringSystem
//
//  Created by Globussoft 1 on 2/10/15.
//  Copyright (c) 2015 Globussoft. All rights reserved.
//

#import "ChangePassword.h"
#import "SingeltonClass.h"

@interface ChangePassword ()

@end

@implementation ChangePassword

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}


-(IBAction)changePassword:(id)sender{
    NSString *soapMesage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<ChangePassword  xmlns=\"http://tempuri.org/\">\n"
                          "<EmailId>%@</EmailId>\n"
                        "<OldPassword>%@</OldPassword>\n"
                          "<NewPassword>%@</NewPassword>\n"
                           "<AccessToken>%@</AccessToken>\n"
                          "</ChangePassword>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",[SingeltonClass sharedSingleton].emailId,[self.oldPassword stringValue],[self.nwPassword stringValue],[SingeltonClass sharedSingleton].token ];
    
    NSString *strInsertUrl=[NSString stringWithFormat:@"%@op=ChangePassword",WebLink];
    NSURL *insertUrl=[NSURL URLWithString:strInsertUrl];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:insertUrl];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMesage length]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/ChangePassword" forHTTPHeaderField:@"SOAPAction"];
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

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI  qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"ChangePasswordResult"]) {
        
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([string isEqualToString:@"\"true\""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Password Changed"];
        [alert setInformativeText:@"Login credential successfuly changed."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{


}

-(IBAction)CancelAction:(id)sender{

}
-(IBAction)backAction:(id)sender{

}
@end
