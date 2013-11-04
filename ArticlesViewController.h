//
//  ArticlesViewController.h
//  IAE
//
//  Created by Philippe Nougaillon on 24/10/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticlesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
