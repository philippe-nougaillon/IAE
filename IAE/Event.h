//
//  Event.h
//  IAE
//
//  Created by Philippe Nougaillon on 20/01/2014.
//  Copyright (c) 2014 Philippe Nougaillon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * addedToCalendar;
@property (nonatomic, retain) NSString * nid;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * when;

@end
