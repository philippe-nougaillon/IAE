//
//  NSString+stringWithDateUSContent.m
//  IAE
//
//  Created by Philippe Nougaillon on 10/01/2014.
//  Copyright (c) 2014 Philippe Nougaillon. All rights reserved.
//

#import "NSString+stringWithDateUSContent.h"

@implementation NSString (stringWithDateUSContent)

+(NSString*)stringDateWithDateUSContent:(NSString*)dateString {

    // conversion de string en date format US
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateUS = [dateFormatter dateFromString:dateString];
    
    // conversion date US en string FR
    NSDateFormatter *dateFormatterFR = [[NSDateFormatter alloc] init];
    [dateFormatterFR setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatterFR setDateStyle:NSDateFormatterFullStyle];
    [dateFormatterFR setLocale:[NSLocale currentLocale]];
    //[dateFormatterFR setDateFormat:@"dd MMM yyyy HH:mm"];
    [dateFormatterFR setDateFormat:@"dd MMM yyyy"];
    NSString *dateFR = [dateFormatterFR stringFromDate:dateUS];
    
    return dateFR;
}

+(NSString*)stringDateSmallWithDateUSContent:(NSString*)dateString {

    // conversion de string en date format US
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateUS = [dateFormatter dateFromString:dateString];
    
    // conversion date US en string FR
    NSDateFormatter *dateFormatterFR = [[NSDateFormatter alloc] init];
    [dateFormatterFR setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatterFR setDateStyle:NSDateFormatterFullStyle];
    [dateFormatterFR setLocale:[NSLocale currentLocale]];
    //[dateFormatterFR setDateFormat:@"dd MMM yyyy HH:mm"];
    [dateFormatterFR setDateFormat:@"dd MMM"];
    NSString *dateFR = [dateFormatterFR stringFromDate:dateUS];

    return dateFR;
}


@end
