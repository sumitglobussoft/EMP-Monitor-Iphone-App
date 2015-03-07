//
//  SingeltonClass.h
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/24/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingeltonClass : NSObject
@property (nonatomic) BOOL checkView;
@property (nonatomic,strong)NSString* macID;
@property (nonatomic,strong)NSString *emailId;
@property (nonatomic,strong)NSString *token;
@property (nonatomic) NSInteger workingTime,nonWorkingTime;
@property (nonatomic,strong)NSString *accessToken;
@property (nonatomic,strong)NSString *accessTokenSecret;
@property (nonatomic,strong)NSString *UserID;
@property(nonatomic,strong)NSString *TokenDropBoxAppKey;
@property(nonatomic,strong)NSString *TokenDropBoxAppSecret;
@property (nonatomic,strong)NSString *logSheetId;
@property(nonatomic,strong)NSString *browserHistoryID;
@property(nonatomic)NSInteger nonWorkingInterVal;
@property(nonatomic)NSInteger workingInterVal,totalTime;
+(SingeltonClass*)sharedSingleton;

@end

