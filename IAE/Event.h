//
//  Event.h
//  IAE
//
//  Created by Philippe Nougaillon on 18/12/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * nid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * when;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * addedToCalendar;

@end
