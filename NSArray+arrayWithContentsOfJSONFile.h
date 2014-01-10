//
//  NSArray+arrayWithContentsOfJSONFile.h
//  IAE
//
//  Created by Philippe Nougaillon on 10/01/2014.
//  Copyright (c) 2014 Philippe Nougaillon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (arrayWithContentsOfJSONFile)
+(NSArray*)arrayWithContentsOfJSONFile:(NSString*)fileLocation;
@end
