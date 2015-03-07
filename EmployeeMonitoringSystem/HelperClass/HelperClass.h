//
//  HelperClass.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 18/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperClass : NSObject
+(NSString *)stripTags:(NSString *)webPage startString:(NSString *)strStart upToString:(NSString *)strEnd;
@end
