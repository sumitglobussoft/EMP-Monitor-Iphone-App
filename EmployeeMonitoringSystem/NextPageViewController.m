//
//  NextPageViewController.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/13/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import "NextPageViewController.h"
#import "SettingViewController.h"
#import "ChangePassword.h"
#import "SingeltonClass.h"
#import "HelperClass.h" 
#import "LogInViewController.h"
#import "TaskModelWindow.h"

@interface NextPageViewController ()

@end

@implementation NextPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
       
//        [ self addChildViewController:settings];

        strBrowserHistroy=[[NSMutableString alloc]init];
        strKeyStrokes=[[NSMutableString alloc]init];
        
      
       
        self.pageView.hidden=NO;
        self.changePasswordView.hidden=YES;
        [self runningApplicationTrack];
        
//    [NSThread detachNewThreadSelector:@selector(myThreadMainMethod:) toTarget:self withObject:nil];
       
        [self myThreadMainMethod:nil];
    }
    return self;
}


-(void)viewDidLoad{

     [self userEvents];
    self.previousDate=self.logInDate;
    [self getNotification];
    [self.workingHrs setStringValue:@" 00 : 00 : 00 "];
    [self.nonWorkingHrs setStringValue:@" 00 : 00 : 00 "];

}

- (IBAction)settingBtnAction:(id)sender {
    settings=[[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    [self.pageView removeFromSuperview];
    [self.view addSubview:settings.view];
}

-(void)myThreadMainMethod:(NSThread *)thread{
   
    NSLog(@"BACKGROUND THREAD");
  timer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getBrowserHistory) userInfo:nil repeats:YES];
 [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

-(void)getBrowserHistory{
    strBrowserHistroy=[[NSMutableString alloc] init];
    strKeyStrokes=[[NSMutableString alloc] init];
    currentActiveApp=[[NSMutableString alloc] init];
    [self getChromeHistory];
    [self getSafariHistory];
    [self getMozillaHistory];
    [self insertIntoLogSheet];
}

-(void)insertIntoLogSheet{
    
    if ([strKeyStrokes isEqualToString:@""]) {
        [strKeyStrokes appendString:@"No keyStrokes"];
    }
    if ([strBrowserHistroy isEqualToString:@""]) {
        [strBrowserHistroy appendString:@"No BrowserHistory"];
    }

    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy hh:mm:ss"];
        //Optionally for time zone conversions
  
    
    NSString *stringFromDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"inserting in to Log Sheet ");
    
        NSString *soapMesage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<UpdateKeystrokesandbrowserhistories xmlns=\"http://tempuri.org/\">\n"
                          "<EmailId>%@</EmailId>\n"
                          "<AccessToken>%@</AccessToken>\n"
                        "<KeystrokesAndBrowserHistories_Id>%@</KeystrokesAndBrowserHistories_Id>\n"
                          "<ApplicationsUsed>%@</ApplicationsUsed>\n"
                          "<BrowserHistory>%@</BrowserHistory>\n"
                          "<Keystrokes>%@</Keystrokes>\n"
                          "<TimeStmp>%@</TimeStmp>\n"
                          "</UpdateKeystrokesandbrowserhistories>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",[SingeltonClass sharedSingleton].emailId,[SingeltonClass sharedSingleton].token,[SingeltonClass sharedSingleton].browserHistoryID,currentActiveApp,strBrowserHistroy,strKeyStrokes,stringFromDate];
    NSString *strLoginUrl=[NSString stringWithFormat:@"%@op=UpdateKeystrokesandbrowserhistories",WebLink];
    NSURL *logInUrl=[NSURL URLWithString:strLoginUrl];
    NSMutableURLRequest *urlRequest=[[NSMutableURLRequest alloc]initWithURL:logInUrl];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMesage length]];
    [urlRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"api.empmonitor.com" forHTTPHeaderField:@"Host"];
    [urlRequest addValue:@"http://tempuri.org/UpdateKeystrokesandbrowserhistories" forHTTPHeaderField:@"SOAPAction"];
    [urlRequest addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[soapMesage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
//    NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSString *responsed=[HelperClass stripTags:xmlString startString:@"{" upToString:@"}"];

    
    
}

- (IBAction)signOutBtnAction:(id)sender {
    NSLog(@"Log In Date==%@",self.logInDate);
    signOutDate=[NSDate date];
    NSLog(@"Log Out Date==%@",signOutDate);
    arrMozHistory=[[NSMutableArray alloc]init];
    arrChromeHistory=[[NSMutableArray alloc]init];
    arrSafari=[[NSMutableArray alloc]init];
    [self getMozillaHistory];
    [self getChromeHistory];
    [self getSafariHistory];
    [self updateLogSheets];
    
    [self.pageView setHidden:YES];
    LogInViewController *loginWindow=[[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
    [self.view addSubview:loginWindow.view];
   
}



-(void)getMozillaHistory
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask,YES);
   NSFileManager *fileManager =[NSFileManager defaultManager ];

    NSString *dirPath=[paths objectAtIndex:0];
    NSString *path1=[dirPath stringByAppendingPathComponent:@"Firefox"];
    NSString *path2=[path1 stringByAppendingPathComponent:@"Profiles"];
   NSArray *filePathsArray = [fileManager subpathsOfDirectoryAtPath:path2  error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF EndsWith '.default'"];
    NSArray *str =  [filePathsArray filteredArrayUsingPredicate:predicate];

    NSString *path3=[str[0] stringByAppendingPathComponent:@"places.sqlite"];
    NSLog(@"Path==%@",path3);
      NSString *finaldbPath=[path2 stringByAppendingPathComponent:path3];
    const char *query="SELECT *from moz_places";
    static sqlite3_stmt *statement;
    if (sqlite3_open([finaldbPath UTF8String],&databaseMoz)!=SQLITE_OK) {
        NSLog(@"Error to open");
    }
    if (sqlite3_prepare_v2(databaseMoz,query, -1,&statement,NULL)==SQLITE_OK) {
        NSLog(@"Prepared");
    }
     NSDate *crntDate=[NSDate date];
    while (sqlite3_step(statement)==SQLITE_ROW)
    {

    //For url and Time stamp
        char *urlChars = (char *) sqlite3_column_text(statement, 1);
//        NSString *strUrl=[NSString stringWithFormat:@"%s",urlChars];
//        [strBrowserHistroy appendString:[NSString stringWithFormat:@",%@",strUrl]];
//        [arrMozHistory addObject:strUrl];

        double timestmp=sqlite3_column_double(statement, 9);
        if (timestmp != 0) {
        NSString *strtimestmp=[NSString stringWithFormat:@"%f",timestmp];
            strtimestmp=[strtimestmp substringToIndex:10];
        NSTimeInterval interval=[strtimestmp doubleValue];
        NSDate *dateVisit=[NSDate dateWithTimeIntervalSince1970:interval];
            if (([dateVisit compare:self.previousDate]==NSOrderedDescending) && ([dateVisit compare:crntDate]==NSOrderedAscending)) {
                NSString *strUrl=[NSString stringWithFormat:@"%s",urlChars];
                
                NSLog(@"url is %@",strUrl);
                [strBrowserHistroy appendString:[NSString stringWithFormat:@",%@",strUrl]];
                [arrMozHistory addObject:strUrl];
            }
        }
    }
      self.previousDate=[NSDate date];
    NSLog(@"previous date ==%@",self.previousDate);

}
-(void)getChromeHistory
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask,YES);
    NSString *dirPath=[paths objectAtIndex:0];
    NSString *tempPath=[dirPath stringByAppendingPathComponent:@"Emp-Chrome_History"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
   
    NSString *path1=[dirPath stringByAppendingPathComponent:@"Google"];
    NSString *path2=[path1 stringByAppendingPathComponent:@"Chrome"];
    NSString *path3=[path2 stringByAppendingPathComponent:@"Default"];
    NSString *finaldbPath=[path3 stringByAppendingPathComponent:@"History"];
    NSLog(@"Path==%@",finaldbPath);
    NSError *error;
    if (![fileManager fileExistsAtPath:tempPath]) {
    [fileManager copyItemAtPath:path3 toPath:tempPath error:&error];
    }else{
        [fileManager removeItemAtPath:tempPath error:&error];
     [fileManager copyItemAtPath:path3 toPath:tempPath error:&error];
    
    }
   
   NSString *tempLocal= [tempPath stringByAppendingPathComponent:@"History"];
    const char *query="SELECT *from urls";
    static sqlite3_stmt *statement;
//    if (sqlite3_open([finaldbPath UTF8String],&databaseChrome)!=SQLITE_OK) {
//        NSLog(@"Error to open");
//    }
    
    if (sqlite3_open([tempLocal UTF8String],&databaseChrome)!=SQLITE_OK) {
        NSLog(@"Error to open");
    }
    
//    if (sqlite3_open([finaldbPath UTF8String],&databaseChrome)!=SQLITE_OK) {
//        NSLog(@"Error to open");
//    }
    if (sqlite3_prepare_v2(databaseChrome,query,-1,&statement,NULL)!=SQLITE_OK) {
        NSLog(@"Prepared");
    }
    NSDate *crntDate=[NSDate date];
    while (sqlite3_step(statement)==SQLITE_ROW)
    {
                //For url and Time stamp
        char *urlChars = (char *) sqlite3_column_text(statement, 1);
        double timestmp=sqlite3_column_double(statement, 5);
        double timestmpChrome=(timestmp-11644473600000000)/1000;
        
        if (timestmp !=0) {
            NSString *strtimestmp=[NSString stringWithFormat:@"%f",timestmpChrome];
            strtimestmp=[strtimestmp substringToIndex:10];
            NSTimeInterval interval=[strtimestmp doubleValue];
            NSDate *dateVisit=[NSDate dateWithTimeIntervalSince1970:interval];
//            NSLog(@"Date===%@",dateVisit);
            if (([dateVisit compare:self.previousDate]==NSOrderedDescending) && ([dateVisit compare:crntDate]==NSOrderedAscending)) {
                NSString *strUrl=[NSString stringWithFormat:@"%s",urlChars];
                [strBrowserHistroy appendString:[NSString stringWithFormat:@",%@",strUrl]];
                [arrChromeHistory addObject:strUrl];
            }
        }
    }
    self.previousDate=[NSDate date];
    NSLog(@"Chrome History==%@",arrChromeHistory);

}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification{

    NSLog(@"notification %@",notification);
    NSInteger ints= [self.stateBox indexOfSelectedItem];
    if ((ints==3&&[self.stateBox.objectValueOfSelectedItem isEqualToString:@"Out For Meal"])||(ints==5&&[self.stateBox.objectValueOfSelectedItem isEqualToString:@"On Break"])) {
        return;
        
    }else if ((ints==6&&[self.stateBox.objectValueOfSelectedItem isEqualToString:@"Sign Out"])){
    
    }else{
    TaskModelWindow *modelWindow=[[TaskModelWindow alloc]initWithNibName:@"TaskModelWindow" bundle:nil];
    modelWindow.statusStr=self.stateBox.objectValueOfSelectedItem;
    NSLog(@"object value of selected item %@",self.stateBox.objectValueOfSelectedItem);
    [self presentViewControllerAsModalWindow:modelWindow];
    }
  }

-(void)getSafariHistory
{
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES);
    NSString *dirPath=[path objectAtIndex:0];
    NSString *safariDirPath=[dirPath stringByAppendingPathComponent:@"Safari"];
    NSString *filePath=[safariDirPath stringByAppendingPathComponent:@"History.plist"];
    NSMutableDictionary *data=[[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    NSMutableArray *arr=[data objectForKey:@"WebHistoryDates"];
    for (int i=0;i<[arr count];i++) {
        NSDictionary *dict=[arr objectAtIndex:i];
        NSString *strVisitDate=[dict objectForKey:@"lastVisitedDate"];
        CFTimeInterval interval=([strVisitDate doubleValue]);
        NSDate *dateVisit=[NSDate dateWithTimeIntervalSinceReferenceDate:interval];
        NSLog(@"timeInterval==%@",dateVisit);
         NSDate *crntDate=[NSDate date];
        if (([dateVisit compare:self.logInDate]==NSOrderedDescending) && ([dateVisit compare:signOutDate]==NSOrderedAscending))
        {
            NSString *strUrl=[dict objectForKey:@""];
            [strBrowserHistroy appendString:[NSString stringWithFormat:@",%@",strUrl]];
            [arrSafari addObject:[dict objectForKey:@""]];
        }
    }
      self.previousDate=[NSDate date];
    
    NSLog(@"Safari History %@",arrSafari);
}
-(void)userEvents
{
    NSString *strTime=[NSString stringWithFormat:@"00:00:00"];
    [self.workingHrs setStringValue:strTime];
    [self.nonWorkingHrs setStringValue:@"00:00:00"];
    initDate=self.logInDate;
    prevDate=self.logInDate;
   
  [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask|NSLeftMouseUpMask|NSRightMouseUpMask handler:^(NSEvent *mouseEvent)
     {
         NSDate *currentdate=[NSDate date];
         NSTimeInterval interVal=[currentdate timeIntervalSinceDate:prevDate];
         NSInteger time=round(interVal);
            if (time>10)
         {
             NSLog(@"Time Inactive==%ld",(long)time);
             [SingeltonClass sharedSingleton].nonWorkingInterVal= [SingeltonClass sharedSingleton].nonWorkingInterVal+time;
          }
         
         
         NSTimeInterval totalTimeInterVal=[currentdate timeIntervalSinceDate:initDate];
         [SingeltonClass sharedSingleton].totalTime=round(totalTimeInterVal);
         NSLog(@" [SingeltonClass sharedSingleton].totalTime %ld", (long)[SingeltonClass sharedSingleton].totalTime);
         if ([SingeltonClass sharedSingleton].totalTime>=60) {
             [self getWorkingTime];
         }
        prevDate=currentdate;
     }];
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *keyEvent)
     {
         NSDate *currentdate=[NSDate date];
         
         NSLog(@"Prev Key Date==%@",prevDate);
         NSString *str=[keyEvent characters];
        
         [strKeyStrokes appendString:[NSString stringWithFormat:@"%@",str]];
         NSTimeInterval totalTimeInterVal=[currentdate timeIntervalSinceDate:initDate];
         [SingeltonClass sharedSingleton].totalTime=round(totalTimeInterVal);
         if ([SingeltonClass sharedSingleton].totalTime>=60)
         {
             [self getWorkingTime];
         }
      prevDate=currentdate;
    }];
   
   [[NSUserNotificationCenter defaultUserNotificationCenter]setDelegate:self];
 
}


- (void)interpretKeyEvents:(NSArray *)eventArray{

    NSLog(@"%@",eventArray);

}

-(void)getNotification
{
    NSUserNotification *notification=[[NSUserNotification alloc]init];
    notification.title=@"Employee Monitoring System";
    notification.informativeText=@"Your are Working From";
    NSTimeInterval interVal=60.0;
   notification.deliveryDate=[NSDate dateWithTimeInterval:interVal sinceDate:self.logInDate];
    [[NSUserNotificationCenter defaultUserNotificationCenter]scheduleNotification:notification];
    
}
-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification{
//    [self getNotification];

}
-(void)getWorkingTime
{

    [SingeltonClass sharedSingleton].workingInterVal=[SingeltonClass sharedSingleton].totalTime-[SingeltonClass sharedSingleton].nonWorkingInterVal;

    [SingeltonClass sharedSingleton].workingTime=[SingeltonClass sharedSingleton].workingTime+[SingeltonClass sharedSingleton].workingInterVal;
    [SingeltonClass sharedSingleton].nonWorkingTime=[SingeltonClass sharedSingleton].nonWorkingTime+[SingeltonClass sharedSingleton].nonWorkingInterVal;
         [self updateTimelbl];
        [SingeltonClass sharedSingleton].workingInterVal=0;
        [SingeltonClass sharedSingleton].nonWorkingInterVal=0;
        [SingeltonClass sharedSingleton].totalTime=0;
        initDate=[NSDate date];
}

-(void)updateTimelbl
{

    int time=(int)[SingeltonClass sharedSingleton].nonWorkingTime;
    int min=time/60;
    int minute,hour;
    if (min>60)
    {
        hour=min/60;
        minute=min%60;
    }
    else
    {
        minute=min;
        hour=0;
    }
    int sec=time%60;
    NSLog(@"Hour==%d,Min==%d,Sec==%d",hour,minute,sec);
    NSString *strNonWorkingTime,*strHour,*strMin,*strSec;
    if (hour<10)
    {
        strHour=[NSString stringWithFormat:@"0%i",hour];
    }
    else
    {
        strHour=[NSString stringWithFormat:@"%i",hour];
    }
    if (minute<10) {
        strMin=[NSString stringWithFormat:@"0%i",minute];
    }
    else
    {
        strMin=[NSString stringWithFormat:@"%i",minute];

        
    }
    if (sec<10) {
        strSec=[NSString stringWithFormat:@"0%i",sec];
    }
    else {
        strSec=[NSString stringWithFormat:@"%i",sec];
    }
    strNonWorkingTime=[NSString stringWithFormat:@"%@:%@:%@",strHour,strMin,strSec];
    [self.nonWorkingHrs setStringValue:strNonWorkingTime];
    NSString *strWorkingTime;
    time=(int)[SingeltonClass sharedSingleton].workingTime;
    min=time/60;
    if (min>60)
    {
        hour=min/60;
        minute=min%60;
    }
    else
    {
        hour=0;
        minute=min;
    }
    sec=time%60;
//    NSLog(@"Working Time==Hour==%d,Min==%d,Sec==%d",hour,minute,sec);
    if (hour<10)
    {
        strHour=[NSString stringWithFormat:@"0%i",hour];
    }
    else
    {
        strHour=[NSString stringWithFormat:@"%i",hour];
    }
    if (minute<10) {
        strMin=[NSString stringWithFormat:@"0%i",minute];
    }
    else
    {
        strMin=[NSString stringWithFormat:@"%i",minute];
        
        
    }
    if (sec<10) {
        strSec=[NSString stringWithFormat:@"0%i",sec];
    }
    else {
        strSec=[NSString stringWithFormat:@"%i",sec];
    }
    strWorkingTime=[NSString stringWithFormat:@"%@:%@:%@",strHour,strMin,strSec];
    [self.workingHrs setStringValue:strWorkingTime];

}

-(void)runningApplicationTrack{
    currentActiveApp=[[NSMutableString alloc] init];
    
  [NSTimer scheduledTimerWithTimeInterval:1.0f    target:self   selector:@selector(runProcess)
    userInfo:nil  repeats:YES];
    
}




- (void)runProcess {
    for (NSRunningApplication *currApp in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if ([currApp isActive]) {
            if (![[oldApp localizedName]isEqualToString:[currApp localizedName]]) {
              
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MM-YYYY hh:mm:ss a"];
                
                NSString *date=[dateFormatter stringFromDate:[NSDate date]];
       [currentActiveApp appendFormat:@"%@<:><:><:>%@/",date,[currApp localizedName]];
                oldApp=currApp ;

            }
            
        } else {
            
        }
    }
    
}


-(void)updateLogSheets
{
    NSLog(@"signOutDate==%@",signOutDate);
    NSString *strWorkingHrs=[NSString stringWithFormat:@"%ld",(long)[SingeltonClass sharedSingleton].workingTime];
    NSString *strNonWorkingHrs=[NSString stringWithFormat:@"%ld",(long)[SingeltonClass sharedSingleton].nonWorkingTime];
    NSInteger totalWorkingTime=[SingeltonClass sharedSingleton].workingTime+[SingeltonClass sharedSingleton].nonWorkingTime;
  NSString *strTotalTime=[NSString stringWithFormat:@"%ld",totalWorkingTime];
    NSString *soapMessage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                           "<soap:Body>\n"
                         "<UpdateLogSheet xmlns=\"http://tempuri.org/\">\n"
                           "<UsersEmailId>%@</UsersEmailId>\n"
                           "<AccessToken>%@</AccessToken>\n"
                           "<LogSheets_Id>%@</LogSheets_Id>\n"
                           "<LogoutTime>%@</LogoutTime>"
                           "<WorkingHours>%@</WorkingHours>"
                           "<NonWorkingHours>%@</NonWorkingHours>"
                           "<TotalHours>%@</TotalHours>"
                           "</UpdateLogSheet>\n"
                           "</soap:Body>\n"
                           "</soap:Envelope>\n",[SingeltonClass sharedSingleton].emailId,[SingeltonClass sharedSingleton].token,[SingeltonClass sharedSingleton].logSheetId,signOutDate,strWorkingHrs,strNonWorkingHrs,strTotalTime];
    
    NSString *strUpdateUrl=[NSString stringWithFormat:@"%@op=UpdateLogSheet",WebLink];
    NSURL *updateUrl=[NSURL URLWithString:strUpdateUrl];
    request=[[NSMutableURLRequest alloc]initWithURL:updateUrl];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"api.empmonitor.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"http://tempuri.org/UpdateLogSheet" forHTTPHeaderField:@"SOAPAction"];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;NSError *error;
     NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
   
}



-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Failed");
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [updateData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 NSString *xmlString = [[NSString alloc] initWithData:updateData encoding:NSUTF8StringEncoding];
    NSLog(@"Xml String==%@",xmlString);
}
- (IBAction)changePasswrdAction:(id)sender
{
   changePswdView=[[ChangePassword alloc] initWithNibName:@"ChangePassword" bundle:nil];
    [self.pageView setHidden:YES];
    [self.view addSubview:changePswdView.view];
    
    
    
}

/*- (IBAction)applychangePassword:(id)sender {
    if ([[self.newPassword stringValue]isEqualToString:[self.reenterPassword stringValue]]) {
        NSLog(@"Old Password==%@",[_oldPassword stringValue]);
        NSLog(@"New Password==%@",[_newPassword stringValue]);
        NSLog(@"Reenter Password==%@",[_reenterPassword stringValue]);
        NSString *soapMessage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                               "<soap:Body>\n"
                               "<ChangePassword xmlns=\"http://apiempmonitorv1.azurewebsites.net/Services/AmazonDB/\">\n"
                               "<EmailId>%@</EmailId>\n"
                               "<OldPassword>%@</OldPassword>\n"
                               "<NewPassword>%@</NewPassword>\n"
                               "<AccessToken>%@</AccessToken>\n"
                               "</ChangePassword>\n"
                               "</soap:Body>\n"
                               "</soap:Envelope>\n",[SingeltonClass sharedSingleton].emailId,[self.oldPassword stringValue],[self.newPassword stringValue],[SingeltonClass sharedSingleton].accessToken];
        NSString *strChangePassUrl=[NSString stringWithFormat:@"%@op=ChangePassword",WebLink];
        NSURL *changePassUrl=[NSURL URLWithString:strChangePassUrl];
        NSMutableURLRequest *request1=[[NSMutableURLRequest alloc]initWithURL:changePassUrl];
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
        [request1 addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request1 addValue:@"http://tempuri.org/ChangePassword" forHTTPHeaderField:@"SOAPAction"];
        [request1 addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [request1 setHTTPMethod:@"POST"];
        [request1 setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
        [NSURLConnection connectionWithRequest:request1 delegate:self];
        NSURLResponse *response;
        NSError *error;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&response error:&error];
        NSString *xmlString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"String Value==%@",xmlString);
        if ([xmlString rangeOfString:@"true"].location!=NSNotFound) {
            [self.newPassword setStringValue:@""];
            [self.oldPassword setStringValue:@""];
            [self.reenterPassword setStringValue:@""];
            [self.changePasswordView setHidden:YES];
            [self.pageView setHidden:NO];
        }

        
    }

}*/

- (IBAction)cancelBtnAction:(id)sender {
    
//    [self.newPassword setStringValue:@""];
//    [self.oldPassword setStringValue:@""];
//    [self.reenterPassword setStringValue:@""];
    [self.changePasswordView setHidden:YES];
    [self.pageView setHidden:NO];
  
}
@end
