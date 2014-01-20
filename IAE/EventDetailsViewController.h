//
//  EventDetailsViewController.h
//  IAE
//
//  Created by Philippe Nougaillon on 06/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailsViewController : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (weak,nonatomic) NSString *indexOfEvent;
@property (weak,nonatomic) NSString *eventTitre;
@property (weak,nonatomic) NSString *eventDate;
@property (weak,nonatomic) NSDate *eventDateUS;
@property (weak,nonatomic) NSNumber *eventAddedToCalendar;
@end
