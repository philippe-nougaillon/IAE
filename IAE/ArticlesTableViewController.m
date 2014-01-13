//
//  ArticlesTableViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 08/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "Reachability.h"
#import "AppDelegate.h"

#import "ArticlesTableViewController.h"
#import "ArticlesCell.h"
#import "ArticleDetailsViewController.h"
#import "PlanningViewController.h"
#import "Article.h"
#import "NSArray+arrayWithContentsOfJSONFile.h"
#import "NSString+stringWithDateUSContent.h"

@interface ArticlesTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *articlesTableView;
@property (nonatomic,strong) NSArray *fetchedRecordsArray;
@end


@implementation ArticlesTableViewController
@synthesize fetchedRecordsArray = _fetchedRecordsArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get localdata or remote if first launch
    [self loadData];

}

- (void)viewDidAppear:(BOOL)animated
{
    // register to refresh UI when ApplicationDidBecomeActive
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(refreshArticlesList)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

-(void)loadData
{
    // load data from local items or stored items
    //
    
    Reachability *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];

    // check if network is up
    if(remoteHostStatus != NotReachable) {

        NSLog(@"[Articles]loadData->Connection ok, first load of Articles");
        //Start an activity indicator here
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center=self.view.center;
        [activityView startAnimating];
        [self.view addSubview:activityView];
       
        // setup database context
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        // check if database exist
        if ([appDelegate isDatabaseExist:@"Article" ]) {
            NSLog(@"[Articles]loadData->database exist");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // get all items
                _fetchedRecordsArray = [self getAllArticles];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // refresh tableview with local data
                    [self.tableView reloadData];
                });
            });
        } else {
            NSLog(@"[Articles]loadData->database NOT exist");
            // reload data from json and store items
            [self addAllRemoteArticlesToLocalDatabase];
            _fetchedRecordsArray = [self getAllArticles];
            [self.tableView reloadData];
        }
        // hide activity monitor
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [activityView removeFromSuperview];
    } else {
        NSLog(@"[Articles]loadData->Connection not OK");
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Pas de connection" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        alertView1.alertViewStyle = UIAlertViewStyleDefault;
        [alertView1 show];
    }
}


- (IBAction)refreshButtonPressed:(id)sender {
    
    [self refreshArticlesList];

}

-(void)refreshArticlesList {
 
    // Check if remote data are more recent
    //
    
    Reachability *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    // check if network is up
    if(remoteHostStatus != NotReachable) {

        NSLog(@"[Articles]refreshArticlesList");
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        //Start an activity indicator here
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center = self.view.center;
        [activityView startAnimating];
        [self.view addSubview:activityView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Check if remote data are more recent
            BOOL refresh = [self refreshLocalData];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (refresh) {
                    // refresh tableview with local data
                    _fetchedRecordsArray = [self getAllArticles];
                    [self.tableView reloadData];
                    NSLog(@"[Articles]refreshArticlesList->tableView reloadData");
                }
                [activityView removeFromSuperview];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
                // register to refresh UI when ApplicationDidBecomeActive
                [[NSNotificationCenter defaultCenter]addObserver:self
                                                        selector:@selector(refreshArticlesList)
                                                            name:UIApplicationDidBecomeActiveNotification
                                                          object:nil];
            });
        });
    } else {
        NSLog(@"[Articles]refreshArticlesList->No connection");
    }
}

-(BOOL)refreshLocalData {
    
    //
    // check if json is more recent than local items
    //
    BOOL refreshLocalData = NO;
    
    NSLog(@"[Articles]refreshLocalData");
    
    // read json remote source
    NSArray *jsonArray = [NSArray arrayWithContentsOfFile:[@PRODSERVER stringByAppendingString:@"rest/actualites"]];
    
    //get first article nid
    NSDictionary *obj = [jsonArray firstObject];
    NSString *remoteArticleNid = [obj objectForKey:@"nid"];
    
    // get last article in local storage
    Article *localFirstArticle = [_fetchedRecordsArray firstObject];
    int localNid = [localFirstArticle.nid intValue];
    
    // add each new remote item
    for (int index=0; index < jsonArray.count; index++) {
        
        //get Article title and date
        NSDictionary *obj = [jsonArray objectAtIndex:index];
        int remoteNid = [[obj objectForKey:@"nid"] intValue];
        
        // if remote item id is lower then last item id, add it
        if (remoteNid > localNid) {
            NSLog(@"[Articles]adding item id:%@", remoteArticleNid);
            
            // save Item to database
            [self addArticleToLocalDatabase:obj];
            
            refreshLocalData = YES;
            self.navigationController.tabBarItem.badgeValue = @"1";
            
        }
    }
    return refreshLocalData;
}

-(void)addAllRemoteArticlesToLocalDatabase {
    
    NSLog(@"[Articles]addAllRemoteArticlesToLocalDatabase");
    
    // read json remote source
    NSArray *jsonArray = [NSArray arrayWithContentsOfJSONFile:[@PRODSERVER stringByAppendingString:@"rest/actualites"]];
        
    // for each array item
    for (int index=0; index < jsonArray.count; index++) {
        
        //get Article title and date
        NSDictionary *obj = [jsonArray objectAtIndex:index];
        
        // save Item to database
        [self addArticleToLocalDatabase:obj];
    }
}

-(void)addArticleToLocalDatabase:(NSDictionary*)obj {
   
    
    NSLog(@"[Articles]addArticleToLocalDatabase");
    
    // save an item to database
    //
    NSString *titre = [obj objectForKey:@"titre"];
    NSString *nid = [obj objectForKey:@"nid"];
    NSString *dateEvent = [[obj objectForKey:@"when"] objectAtIndex:0];
    NSString *dateFR = [NSString stringDateWithDateUSContent:dateEvent];
   
    // get image filename
    NSString *filePathToImage;
    if (![[obj objectForKey:@"vignette"] isEqual:[NSNull null]]) {
        NSDictionary *imageArray = [obj objectForKey:@"vignette"];
        if (imageArray != NULL) {
            NSString *imageFileName = [imageArray objectForKey:@"filename"];
            
            // load image
            NSString *imagePath = [@PRODSERVER stringByAppendingString:[@"sites/default/files/" stringByAppendingString:imageFileName]];
            NSURL *imageURL = [[NSURL alloc] initWithString:imagePath];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            // save image into app's document folder
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            filePathToImage = [NSString stringWithFormat:@"%@/%@", documentsDirectory, imageFileName];
            [imageData writeToFile:filePathToImage atomically:NO];
        }
    }
    
    // Add Entry to Article Database
    Article *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                      inManagedObjectContext:self.managedObjectContext];
    
    newEntry.title = titre;
    newEntry.nid = nid;
    newEntry.image = filePathToImage;
    newEntry.postDate = dateFR;
    newEntry.read =[NSNumber numberWithInt:0];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"[Articles]addArticleToLocalDatabase->Whoops, couldn't new item save: %@", [error localizedDescription]);
    }
}

-(NSArray*)getAllArticles
{
    
    NSLog(@"[Articles]getAllArticles-> from Local Database");
    
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"nid" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}


#pragma mark - Tableview Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fetchedRecordsArray.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ArticleCell";
    UIColor *blueIAE = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1];

    ArticlesCell *cell = (ArticlesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
    // update cell with article content
    Article *article = [_fetchedRecordsArray objectAtIndex:indexPath.row];
    [cell.titre setText:article.title];
    [cell.date setText:article.postDate];
    if ([article.read intValue] == 1)
        [cell.titre setTextColor:[UIColor grayColor]];
    else
        [cell.titre setTextColor:blueIAE];
    
    UIImage *articleCellImage = [UIImage imageWithContentsOfFile:article.image];
    cell.image.image = articleCellImage;
    
    return cell;
}

# pragma mark -SEGUE

// This will get called too before the view appears
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openDetailView"]) {
        
        // get the index of select item
        ArticlesCell *cell = (ArticlesCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        // which article to open ?
        Article *article = [_fetchedRecordsArray objectAtIndex:indexPath.row];
        
        //mark article as read
        article.read = [NSNumber numberWithInt:1];
        [cell.titre setTextColor:[UIColor grayColor]];

        // update the database
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        // Get destination view
        ArticleDetailsViewController *vc = [segue destinationViewController];
        
        // Pass the information to your destination view
        vc.indexOfArticle = article.nid;
        vc.navigationItem.title = cell.titre.text;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
