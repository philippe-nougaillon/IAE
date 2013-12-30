//
//  EventsCell.h
//  IAE
//
//  Created by Philippe Nougaillon on 05/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleEvent;
@property (weak, nonatomic) IBOutlet UILabel *dateEvent;
@property (weak, nonatomic) IBOutlet UILabel *subTitleEvent;
@property (weak, nonatomic) IBOutlet UIImageView *eventIsIntoCalendar;
@property (weak, nonatomic) IBOutlet UILabel *labelEventAddedToCalendar;
@end
