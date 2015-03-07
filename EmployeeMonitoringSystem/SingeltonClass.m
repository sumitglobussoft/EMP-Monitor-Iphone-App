//
//  SingeltonClass.m
//  EmployeeMonitoringSystem
//
//  Created by GBS-mac on 12/24/14.
//  Copyright (c) 2014 Globussoft. All rights reserved.
//

#import "SingeltonClass.h"

@implementation SingeltonClass

static SingeltonClass *sharedSingleton;
+(SingeltonClass*)sharedSingleton {
    
    @synchronized(self){
        
        if(!sharedSingleton){
            sharedSingleton=[[SingeltonClass alloc]init];
        }
    }
    return sharedSingleton;
}

@end
