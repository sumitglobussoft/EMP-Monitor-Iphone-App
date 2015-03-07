//
//  HelperClass.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 18/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "HelperClass.h"

@implementation HelperClass
//Parse JSON String 
+(NSString *)stripTags:(NSString *)webPage startString:(NSString *)strStart upToString:(NSString *)strEnd{
    
    NSMutableString *html = [NSMutableString stringWithCapacity:[webPage length]];
    NSString *startString=strStart;
    NSString *EndString=strEnd;
    
    NSString *returnString=[[NSString alloc]init];
    NSScanner *scanner = [NSScanner scannerWithString:webPage];
    scanner.charactersToBeSkipped = NULL;
    NSString *tempText = nil;
    
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:startString intoString:&tempText ];
        if (tempText != nil){
            [html appendString:tempText];
        }
        [scanner scanUpToString:EndString intoString:&returnString];
        
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];
        tempText = nil;
    }
    
    return returnString;
}
@end
