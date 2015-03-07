//
//  MainWindowController.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import "MainWindowController.h"
#import "LogInViewController.h"
#import "XMLReader.h"
#import "HelperClass.h"
#import "Base64.h"
#import "SingeltonClass.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
        
    }
    return self;
}
- (void)windowDidLoad
{
    [super windowDidLoad];

    [self.window setBackgroundColor:[NSColor colorWithCalibratedRed:(CGFloat)77/255 green:(CGFloat)31/255 blue:(CGFloat)3/255 alpha:1.0]];
    [self.window setMaxSize:NSSizeFromCGSize(CGSizeMake(900,900))];
   
    [self rememberMe];
//    [self.window.contentView addSubview:logInViewCon.view];


// Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)rememberMe
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
        
        logInViewCon=[[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil];
        [self.window.contentView addSubview:logInViewCon.view];

        NSLog(@"Not Already Login");
        return;
    }else{
        
        
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
        NSLog(@"Login Dict %@ ",dict);
    }
    
    if (wsAccessToken==nil&&email==nil)
    {
        
        NSLog(@"Email Id or Password is incorrect");
        logInViewCon=[[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil];
        [self.window.contentView addSubview:logInViewCon.view];
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
        
            timer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(takePicture) userInfo:nil repeats:YES];
        
            tablePage=[[NextPageViewController alloc]initWithNibName:@"NextPageViewController" bundle:nil];
        NSDate *currentDate=[NSDate date];
        tablePage.logInDate=currentDate;

        [self.window.contentView addSubview:tablePage.view];
        
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
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]userId:[SingeltonClass sharedSingleton].UserID];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
       NSString *destDir1 = [NSString stringWithFormat:@"/EmpMonitor/%@/%@/Reports",email,dateString];
     NSString *destDir2 = [NSString stringWithFormat:@"/EmpMonitor/%@/%@/EventLog",email,dateString];

    self.restClient.delegate = self;
    
    [self.restClient createFolder:destDir1];
    [self.restClient createFolder:destDir2];

}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
        // This gets called when the user clicks Show "App name". You don't need to do anything for Dropbox here
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

-(void)takePicture
{
    [self interograteHardWare];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI  qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if (parser==self.insertXmlParser) {
        
        if ([elementName isEqualToString:@"InsertIntoLogSheetResult"]) {
            
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if (parser==self.insertXmlParser) {
            //passing the value of the current elemtn to the string
        NSString *strID=[string substringFromIndex:5];
        NSLog(@"ID==%@",strID);
        
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
 }

-(BOOL)acceptsFirstResponder
{
    return YES;
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
    NSString *localEmp=[docDirectory stringByAppendingPathComponent:@"EmployeeMonitor"];
    
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
        
            //        [imageArray addObject:[NSString stringWithFormat:@"%@.jpg",timeString]];
        NSString *destDir = [NSString stringWithFormat:@"/EmpMonitor/%@/%@/Screenshots",email,dateString];
        
        [self.restClient uploadFile:[NSString stringWithFormat:@"%@.jpg",timeString] toPath:destDir withParentRev:nil fromPath:getPath];
        self.restClient.delegate=self;
        
    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
   
    [self deleteImage:srcPath];
    
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


- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
     NSString *destPath=[error.userInfo valueForKey:@"destinationPath"];
    NSString *sourcePath=[error.userInfo valueForKey:@"sourcePath"];
    
    NSLog(@"extension --------- %@",[sourcePath lastPathComponent] );
    NSLog(@"path --------- %@",sourcePath  );
    
     [self.restClient uploadFile:[sourcePath lastPathComponent]  toPath:destPath withParentRev:nil fromPath:sourcePath];
   
}

@end
