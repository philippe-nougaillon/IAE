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

    NSLog(@"arrayWithContentsOfJSONFile:%@",fileLocation);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileLocation]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data == nil) {
        NSLog(@"arrayWithContentsOfJSONFile->errorRequest= %@", error);
        return nil;
    }

    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    if (errorDecoding != nil) {
        NSLog(@"arrayWithContentsOfJSONFile-> errorDecoding= %@", errorDecoding);
        return nil;
    } else
        return result;

}

@end
