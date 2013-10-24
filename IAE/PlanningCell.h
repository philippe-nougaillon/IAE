//
//  Cell.h
//  IAE
//
//  Created by Philippe Nougaillon on 02/10/13.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanningCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *heureLabel;
@property (weak, nonatomic) IBOutlet UILabel *salleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titreLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;

@end
