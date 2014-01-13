//
//  ArticlesTableViewController.h
//  IAE
//
//  Created by Philippe Nougaillon on 08/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticlesTableViewController : UITableViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
-(void)loadData;
@end
