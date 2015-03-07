//
//  LogInViewController.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import "LogInViewController.h"
#import "NextPageViewController.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "SingeltonClass.h"
#import "XMLReader.h"
#import "Reachability.h"
#import "Base64.h"

@interface LogInViewController ()

@end
//static int count=0;

@implementation LogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
  
    
       }
    return self;
}

-(void)viewDidLoad{
    
    tablePage=[[NextPageViewController alloc]initWithNibName:@"NextPageViewController" bundle:nil];


}

- (IBAction)logInAction:(id)sender
{
    indexNumber=0;
     imageArray=[[NSMutableArray alloc] init];
    isDropBusy=NO;
    Reachability *reach=[Reachability reachabilityForInternetConnection];
   
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    isNetworkAvilable=[reach startNotifier];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
//    [self.txtFEmail setStringValue:@"khomesh@globussoft.com"];
//  [self.txtFPassword setStringValue:@"qwerty"];
  [self getLogInTime];
  [self performLogInAction];
    
   self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]userId:[SingeltonClass sharedSingleton].UserID];

    self.restClient.delegate = self;
    
}
- (void)reachabilityChanged:(NSNotification*)note {
   
}

-(void)takePicture
{
  [self interograteHardWare];
}

-(void)interograteHardWare
{
    displays=nil;
    CGError          err=CGDisplayNoErr;
    CGDisplayCount   dspCount=0;
    //To set main screen as image to be captured
    err=CGGetActiveDisplayList(0,NULL,&dspCount);
    if (err != CGDisplayNoErr) {
        return;
    }
    if (displays !=nil) {
        free(displays);
    }
    //To allocate memory to displays
    displays=calloc((size_t)dspCount,sizeof(CGDirectDisplayID));
    
    //To get active display
    err = CGGetActiveDisplayList(dspCount,
                                 displays,
                                 &dspCount);
    //To get Current screen Imgae
    CGImageRef image=CGDisplayCreateImage(displays[0]);
   
    storeImg=[[NSImage alloc]initWithCGImage:image size:NSSizeFromCGSize(CGSizeMake(1920,1080))];
    
    CGImageRelease(image);
        [self saveImage];
   }

-(void)saveImage
{
    NSLog(@"new 5 sec");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];

    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH-mm-ss"];
    NSString *timeString = [timeFormatter stringFromDate:[NSDate date]];
    
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  
    
    NSString *docDirectory=[paths objectAtIndex:0];
    NSString *localEmp=[docDirectory stringByAppendingPathComponent:@".EmployeeMonitor"];
    
    NSError  *error;
    if(![[NSFileManager defaultManager] fileExistsAtPath:localEmp]){
        [[NSFileManager defaultManager] createDirectoryAtPath:localEmp withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSString *localDirPath=[localEmp stringByAppendingPathComponent:dateString];

    if(![[NSFileManager defaultManager] fileExistsAtPath:localDirPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:localDirPath withIntermediateDirectories:NO attributes:nil error:&error];
    } //Create folder
   
    NSString *getPath=[localDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",timeString ]];
    NSData *imageData=[storeImg TIFFRepresentation];
    BOOL uploaded=[imageData writeToFile:getPath atomically:YES];
   
    if (uploaded) {

        NSString *destDir = [NSString stringWithFormat:@"/EmpMonitor/%@/%@/Screenshots",[self.txtFEmail stringValue],dateString];
        
            [self.restClient uploadFile:[NSString stringWithFormat:@"%@.jpg",timeString] toPath:destDir withParentRev:nil fromPath:getPath];
            self.restClient.delegate=self;
        
    }
}

-(void)fileUploadSuccess{
  if(isDropBusy==YES)
    {
        isDropBusy=NO;
    
    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
   NSLog(@"File uploaded successfully to path: %@", metadata.path);
    isDropBusy=NO;
    [self deleteImage:srcPath];
    indexNumber++;
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
    NSString *destPath=[error.userInfo valueForKey:@"destinationPath"];
    NSString *sourcePath=[error.userInfo valueForKey:@"sourcePath"];

        isDropBusy=NO;
}

-(void)deleteImage:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
        NSError *error;
        BOOL sucess=[fileManager removeItemAtPath:path error:&error];
        if (sucess) {
            NSLog(@"Sucessfully removed file");
        }
        else
        {
            NSLog(@"Error to remove file");
        }
}


-(void)getLogInTime
{
    NSDate *currentDate=[NSDate date];
    tablePage.logInDate=currentDate;
 
}


- (IBAction)rememberMeAction:(id)sender
{
//   NSString *strMacId=@"902B3439F6444567A";
    NSString *soapMesage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<GetUserUsingMacId xmlns=\"http://tempuri.org/\">\n"
                          "<MacId>%@</MacId>\n"
                          "</GetUserUsingMacId>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",[SingeltonClass sharedSingleton].macID];
    
    NSString *strLoginUrl=[NSString stringWithFormat:@"%@op=GetUserUsingMacId",WebLink];
    NSURL *logInUrl=[NSURL URLWithString:strLoginUrl];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:logInUrl];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMesage length]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/GetUserUsingMacId" forHTTPHeaderField:@"SOAPAction"];
    [request addValue:@"api.empmonitor.com" forHTTPHeaderField:@"Host"];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMesage dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Create URLConnection
//    [NSURLConnection connectionWithRequest:request delegate:self];
   
    NSHTTPURLResponse   * response;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
   
    NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSString *responsed=[HelperClass stripTags:xmlString startString:@"objUsers" upToString:@"}"];
    if ([responsed isEqualToString:@""]) {
        NSLog(@"Not Already Login");
        return;
    }
    NSString *rt=[responsed stringByReplacingOccurrencesOfString:@"objUsers\":" withString:@""];
    
    NSString *jsonStrinb=[NSString stringWithFormat:@"%@}",rt];
    NSData *objectData1 = [jsonStrinb dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData1
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (dict) {
        wsAccessToken=[dict objectForKey:@"AccessToken"];
        [SingeltonClass sharedSingleton].token=wsAccessToken;
        email=[dict objectForKey:@"EmailId"];
        
    }
    
    if (wsAccessToken==nil&&email==nil)
    {
        
        NSLog(@"Email Id or Password is incorrect");
        return;
        
    }
    else
    {
        
            //        [NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];
        NSString *responseStr=[HelperClass stripTags:xmlString startString:@"{" upToString:@"}"];
        NSString *jsonString=[NSString stringWithFormat:@"%@}",responseStr];
        NSLog(@"Json String= %@",jsonString);
        
        NSError *jsonError;
        NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSLog(@"Login Dict =%@",dict);
        NSLog(@"email id %@",email);
        
        acessToken=[dict objectForKey:@"AccessToken"];
        
        
        NSString *jsvonString = [NSString stringWithBase64EncodedString:acessToken];
        NSError *error;
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:jsvonString error:&error];
        
        NSDictionary *valueDict=[xmlDictionary valueForKey:@"ArrayOfKeyValueOfstringstring"];
        NSArray *arr=[valueDict valueForKey:@"KeyValueOfstringstring"];
        NSMutableDictionary *mutDic=[[NSMutableDictionary alloc]init];
        
        for (NSDictionary *dic in arr) {
            NSDictionary *dict1=[dic valueForKey:@"Key"];
            NSDictionary *dict2=[dic valueForKey:@"Value"];
            [mutDic setObject:[dict2 valueForKey:@"text"] forKey:[dict1 valueForKey:@"text"]];
        }
        
        NSLog(@" %@", mutDic);
        [SingeltonClass sharedSingleton].TokenDropBoxAppKey=[mutDic valueForKey:@"TokenDropBoxAppKey"];
        [SingeltonClass sharedSingleton].TokenDropBoxAppSecret=[mutDic valueForKey:@"TokenDropBoxAppSecret"];
        [SingeltonClass sharedSingleton].accessToken=[mutDic valueForKey:@"TokenDropBoxUsername"];
        [SingeltonClass sharedSingleton].accessTokenSecret=[mutDic valueForKey:@"TokenDropBoxPassword"];
        [SingeltonClass sharedSingleton].UserID=[mutDic valueForKey:@"UserID"];
        
        [self setupDBSession];
        
        [SingeltonClass sharedSingleton].emailId=email;
        NSLog(@"Email==%@,AcessToken==%@",[SingeltonClass sharedSingleton].emailId,[SingeltonClass sharedSingleton].token);
        [self interograteHardWare];
        
        [self insertIntoLogSheet];
        
        [_logInView removeFromSuperview];
        [self.view addSubview:tablePage.view];
        
        timer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(takePicture) userInfo:nil repeats:YES];
        
    }
}

#pragma mark=====================
#pragma mark Log In Action
#pragma mark=====================

-(void)performLogInAction
{
    if ((![[self.txtFEmail stringValue]isEqualToString:@""])&&(![[self.txtFPassword stringValue]isEqualToString:@""]))
    {
        
        NSString *soapMesage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                              "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                              "<soap:Body>\n"
                              "<Login xmlns=\"http://tempuri.org/\">\n"
                              "<EmailId>%@</EmailId>\n"
                              "<Password>%@</Password>\n"
                              "<MacId>%@</MacId>\n"
                              "</Login>\n"
                              "</soap:Body>\n"
                              "</soap:Envelope>\n",[self.txtFEmail stringValue],[self.txtFPassword stringValue],[SingeltonClass sharedSingleton].macID];
        NSString *strLoginUrl=[NSString stringWithFormat:@"%@op=Login",WebLink];
        NSURL *logInUrl=[NSURL URLWithString:strLoginUrl];
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:logInUrl];
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMesage length]];
        [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"api.empmonitor.com" forHTTPHeaderField:@"Host"];
        [request addValue:@"http://tempuri.org/Login" forHTTPHeaderField:@"SOAPAction"];
        [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[soapMesage dataUsingEncoding:NSUTF8StringEncoding]];
//        [NSURLConnection connectionWithRequest:request delegate:self];
        logInData = [[NSMutableData alloc]init];
        NSURLResponse *response;
        NSError *error;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
     
       /* self.loginXmlParser = [[NSXMLParser alloc] initWithData:responseData];
        [self.loginXmlParser setDelegate:self];
        [self.loginXmlParser setShouldResolveExternalEntities: YES];
        [self.loginXmlParser parse];*/

    
       NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
     
        NSString *responsed=[HelperClass stripTags:xmlString startString:@"objUsers" upToString:@"}"];
        NSString *rt=[responsed stringByReplacingOccurrencesOfString:@"objUsers\":" withString:@""];

        NSString *jsonStrinb=[NSString stringWithFormat:@"%@}",rt];
        NSData *objectData1 = [jsonStrinb dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData1
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        if (dict) {
            wsAccessToken=[dict objectForKey:@"AccessToken"];
            [SingeltonClass sharedSingleton].token=wsAccessToken;
            email=[dict objectForKey:@"EmailId"];
            
        }
        
        if ([xmlString rangeOfString:[self.txtFEmail stringValue]].location==NSNotFound)
        {
            
            NSLog(@"Email Id or Password is incorrect");
            
        }
        else
        {
            
                //        [NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];
            NSString *responseStr=[HelperClass stripTags:xmlString startString:@"{" upToString:@"}"];
            NSString *jsonString=[NSString stringWithFormat:@"%@}",responseStr];
            NSLog(@"Json String= %@",jsonString);
            
            NSError *jsonError;
            NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            NSLog(@"Login Dict =%@",dict);
            NSLog(@"email id %@",email);
            
            acessToken=[dict objectForKey:@"AccessToken"];
            
            
            NSString *jsvonString = [NSString stringWithBase64EncodedString:acessToken];
            NSError *error;
            NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:jsvonString error:&error];
            
            NSDictionary *valueDict=[xmlDictionary valueForKey:@"ArrayOfKeyValueOfstringstring"];
            NSArray *arr=[valueDict valueForKey:@"KeyValueOfstringstring"];
            NSMutableDictionary *mutDic=[[NSMutableDictionary alloc]init];
            
            for (NSDictionary *dic in arr) {
                NSDictionary *dict1=[dic valueForKey:@"Key"];
                NSDictionary *dict2=[dic valueForKey:@"Value"];
                [mutDic setObject:[dict2 valueForKey:@"text"] forKey:[dict1 valueForKey:@"text"]];
            }
            
            NSLog(@" %@", mutDic);
            [SingeltonClass sharedSingleton].TokenDropBoxAppKey=[mutDic valueForKey:@"TokenDropBoxAppKey"];
            [SingeltonClass sharedSingleton].TokenDropBoxAppSecret=[mutDic valueForKey:@"TokenDropBoxAppSecret"];
            [SingeltonClass sharedSingleton].accessToken=[mutDic valueForKey:@"TokenDropBoxUsername"];
            [SingeltonClass sharedSingleton].accessTokenSecret=[mutDic valueForKey:@"TokenDropBoxPassword"];
            [SingeltonClass sharedSingleton].UserID=[mutDic valueForKey:@"UserID"];
            
            
            
            [self setupDBSession];
            
            [SingeltonClass sharedSingleton].emailId=email;
            NSLog(@"Email==%@,AcessToken==%@",[SingeltonClass sharedSingleton].emailId,[SingeltonClass sharedSingleton].token);
            [self interograteHardWare];
            
            [self insertIntoLogSheet];
            
            [_logInView removeFromSuperview];
            [self.view addSubview:tablePage.view];
            
            timer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(takePicture) userInfo:nil repeats:YES];
            
       }
   }
}

-(void)setupDBSession{

   DBSession *dbSession = [[DBSession alloc]
        initWithAppKey:[SingeltonClass sharedSingleton].TokenDropBoxAppKey
  appSecret:[SingeltonClass sharedSingleton].TokenDropBoxAppSecret
                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    
    [DBSession setSharedSession:dbSession];
    [dbSession updateAccessToken:[SingeltonClass sharedSingleton].accessToken accessTokenSecret:[SingeltonClass sharedSingleton].accessTokenSecret forUserId:[SingeltonClass sharedSingleton].UserID];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];
    
    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:)
          forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    if ([[DBSession sharedSession] isLinked]){
            //        [[DBSession sharedSession]unlinkAll];
        
    }  else {
        [[DBAuthHelperOSX sharedHelper] authenticate];
    }

//    [self awakeFromNib];

}

- (void)authHelperStateChangedNotification:(NSNotification *)notification {
    
    if ([[DBSession sharedSession] isLinked]) {
            // You can now start using the API!
    }
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
        // This gets called when the user clicks Show "App name". You don't need to do anything for Dropbox here
}

-(IBAction)forgotPaswordAction:(id)sender
{
    NSLog(@"Email value is %@",[self.txtFEmail stringValue]);
    if ([[self.txtFEmail stringValue]isEqualToString:@""]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Please enter your email id  ?"];
        [alert setInformativeText:@"Login Credential will send to your email id."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }else{
       NSString *soapMesage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<ForgotPassword  xmlns=\"http://tempuri.org/\">\n"
                          "<EmailId>%@</EmailId>\n"
                         "</ForgotPassword>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",[self.txtFEmail stringValue]];
    
    NSString *strInsertUrl=[NSString stringWithFormat:@"%@op=ForgotPassword",WebLink];
    NSURL *insertUrl=[NSURL URLWithString:strInsertUrl];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:insertUrl];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMesage length]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/ForgotPassword" forHTTPHeaderField:@"SOAPAction"];
    [request addValue:@"api.empmonitor.com" forHTTPHeaderField:@"Host"];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMesage dataUsingEncoding:NSUTF8StringEncoding]];
//    [NSURLConnection connectionWithRequest:request delegate:self];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
  self.forgetXmlParser = [[NSXMLParser alloc] initWithData:[responseData copy]];
    [ self.forgetXmlParser setDelegate:(id)self];
    [ self.forgetXmlParser setShouldResolveExternalEntities: YES];
    [ self.forgetXmlParser parse];
    }
}

-(void)insertIntoLogSheet
{
    NSLog(@"insert in to LogSheet");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *strDate=[formatter stringFromDate:[NSDate date]];
    NSDate *logInDate=[NSDate date];

    NSString *soapMesage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<InsertIntoLogSheet xmlns=\"http://tempuri.org/\">\n"
                          "<LoginTime>%@</LoginTime>\n"
                          "<Date>%@</Date>\n"
                          "<UsersEmailId>%@</UsersEmailId>\n"
                          "<AccessToken>%@</AccessToken>\n"
                          "</InsertIntoLogSheet>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",logInDate,strDate,email,wsAccessToken];
    
    NSString *strInsertUrl=[NSString stringWithFormat:@"%@op=InsertIntoLogSheet",WebLink];
    NSURL *insertUrl=[NSURL URLWithString:strInsertUrl];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:insertUrl];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMesage length]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/InsertIntoLogSheet" forHTTPHeaderField:@"SOAPAction"];
      [request addValue:@"api.empmonitor.com" forHTTPHeaderField:@"Host"];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMesage dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection connectionWithRequest:request delegate:self];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSData* xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    self.insertXmlParser = [[NSXMLParser alloc] initWithData:[xmlData copy]];
    [self.insertXmlParser setDelegate:(id)self];
    [self.insertXmlParser setShouldResolveExternalEntities: YES];
    [self.insertXmlParser parse];
    NSLog(@"String Value1==%@",xmlString);

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI  qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    // SUPPOSE TO READ ALL XML FILE AND FIND ALL "name" ELEMENTS
   
    
    if (parser==self.insertXmlParser) {
        
        if ([elementName isEqualToString:@"InsertIntoLogSheetResult"]) {
            
//            currentName = [[NSMutableString alloc] init];
        }
        
    }

    
    if (parser==self.forgetXmlParser) {
        
        if ([elementName isEqualToString:@"ForgotPasswordResult"]) {
            
//            currentName = [[NSMutableString alloc] init];
        }

    }
    
//    if (parser==self.rememberMeXmlParser) {
//        
//        if ([elementName isEqualToString:@"GetUserUsingMacIdResult"]) {
//            
//                //            currentName = [[NSMutableString alloc] init];
//        }
//        
//    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
     if (parser==self.insertXmlParser) {
        //passing the value of the current elemtn to the string
    NSString *strID=[string substringFromIndex:5];
    NSLog(@"ID==%@",strID);
//    NSString *logSheetId1=[NSString stringWithBase64EncodedString:strID];
    NSString *logSheetId2=[strID stringByReplacingOccurrencesOfString:@"\\u003c:\\u003e\\u003c:\\u003e\\u003c:\\u003e" withString:@"ID"];
     NSString *logSheetId3=[logSheetId2 stringByReplacingOccurrencesOfString:@"00:00:00" withString:@""];
      NSString *responsed1=[logSheetId3 stringByReplacingOccurrencesOfString:@"ID" withString:@" "];
    NSString *trimmedString = [responsed1 stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    NSArray *lastFirst = [trimmedString componentsSeparatedByString:@" "];
     [SingeltonClass sharedSingleton].logSheetId=[lastFirst objectAtIndex:0];
    
    [SingeltonClass sharedSingleton].browserHistoryID=[lastFirst objectAtIndex:1];
    NSLog(@"Id in Integer==%@",[SingeltonClass sharedSingleton].logSheetId);
   
}
    
    if (parser==self.forgetXmlParser) {
            NSLog(@"string Value is %@",string);
        if ([string isEqualToString:@"\"true\""]) {
            NSAlert *alert = [[NSAlert alloc] init];
           [alert addButtonWithTitle:@"OK"];
           [alert setMessageText:@"Request successfully sent"];
           [alert setInformativeText:@"Login Credential will send to your email id ."];
           [alert setAlertStyle:NSWarningAlertStyle];
                        [alert runModal];
        }
    }
    
    
   /* if (parser==self.loginXmlParser) {
        NSError *error;
        NSData *objectData1 = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict1 = [NSJSONSerialization JSONObjectWithData:objectData1
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        NSDictionary *dict2=[dict1 objectForKey:@"objUsers"];
        
        if (dict2) {
            wsAccessToken=[dict2 objectForKey:@"AccessToken"];
            [SingeltonClass sharedSingleton].token=wsAccessToken;
            email=[dict2 objectForKey:@"EmailId"];
            
        }
         NSDictionary *dict3=[dict1 objectForKey:@"objDropbox"];
        acessToken=[dict3 objectForKey:@"AccessToken"];
        NSString *jsvonString = [NSString stringWithBase64EncodedString:acessToken];
 NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:jsvonString error:&error];
    }*/
    
 }


@end
