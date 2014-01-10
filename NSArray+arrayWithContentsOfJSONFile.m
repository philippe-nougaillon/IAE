//
//  NSArray+arrayWithContentsOfJSONFile.m
//  IAE
//
//  Created by Philippe Nougaillon on 10/01/2014.
//  Copyright (c) 2014 Philippe Nougaillon. All rights reserved.
//

#import "NSArray+arrayWithContentsOfJSONFile.h"

@implementation NSArray (arrayWithContentsOfJSONFile)
+(NSArray*)arrayWithContentsOfJSONFile:(NSString*)fileLocation
{

    NSURLResponse *response;
    NSError *error;
    NSError *errorDecoding;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileLocation]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    if (errorDecoding != nil) {
        NSLog(@"errorDecoding= %@", errorDecoding);
        return nil;
    } else
        return result;

}

@end
