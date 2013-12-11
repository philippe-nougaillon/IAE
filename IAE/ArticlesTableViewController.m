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
#import "Article.h"


@interface ArticlesTableViewController () {

    __weak IBOutlet UITableView *articlesTableView;

}
@property (nonatomic,strong)NSArray *fetchedRecordsArray;
@property (nonatomic,strong)NSArray *jsonArray;

@end


@implementation ArticlesTableViewController

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

    // register to refresh UI when ApplicationDidBecomeActive
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(loadData)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];

}

-(void)loadData
{
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    //Start an activity indicator here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    if(remoteHostStatus != NotReachable) {
        
        // setup database context
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        NSLog(@"managed context set");
        
        // check if database exist
        if (appDelegate.isDatabaseExist) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // get all items
                self.fetchedRecordsArray = [self getAllArticles];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // refresh tableview with local data
                    [self.tableView reloadData];
                    
                    // Check if remote data are more recent
                    if ([self refreshLocalData]) {
                        self.fetchedRecordsArray = [self getAllArticles];
                        [self.tableView reloadData];
                    }
                    
                });
            });
        } else {
            // reload data from json and store items
            [self addAllRemoteArticlesToLocalDatabase];
            self.fetchedRecordsArray = [self getAllArticles];
            [self.tableView reloadData];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [activityView removeFromSuperview];
        
    } else {
        NSLog(@"NOT Connected !");
    }

}


- (IBAction)refreshButtonPressed:(id)sender {
    
    [self loadData];

}

-(NSArray*)getRemoteArticles {
    
    // read json remote source
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://iae.philnoug.com/rest/articles.json"]];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSArray *jsonArray;
    NSError *errorDecoding;
    jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    
    return jsonArray;
}

-(BOOL)refreshLocalData {
    
    //
    // check if json is more recent than local items
    //
    
    BOOL refreshLocalData = NO;
    NSLog(@"refresh Local Data");
    
    // read json remote source
    NSArray *jsonArray = [self getRemoteArticles];
    
    //get first article nid
    NSDictionary *obj = [jsonArray firstObject];
    NSString *remoteArticleNid = [obj objectForKey:@"nid"];
    
    // get last article in local storage
    Article *localFirstArticle = [self.fetchedRecordsArray firstObject];
    int localNid = [localFirstArticle.nid intValue];
    
    // add each new remote item
    for (int index=0; index < jsonArray.count; index++) {
        
        //get Article title and date
        NSDictionary *obj = [jsonArray objectAtIndex:index];
        int remoteNid = [[obj objectForKey:@"nid"] intValue];
        
        // if remote item id is lower then last item id, add it
        if (remoteNid > localNid) {
            NSLog(@"adding item id:%@", remoteArticleNid);
            
            // save Item to database
            [self addArticleToLocalDatabase:obj];
            
            refreshLocalData = YES;
        }
    }
    return refreshLocalData;
}

-(void)addAllRemoteArticlesToLocalDatabase {
    
    NSLog(@"store data from json items");
    
    // read json source
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://iae.philnoug.com/rest/articles.json"]];
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSArray *jsonArray;
    NSError *errorDecoding;
    jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    
    // for each array item
    for (int index=0; index < jsonArray.count; index++) {
        
        //get Article title and date
        NSDictionary *obj = [jsonArray objectAtIndex:index];
        
        // save Item to database
        [self addArticleToLocalDatabase:obj];
    }
}

-(void)addArticleToLocalDatabase:(NSDictionary*)obj {
    
    // save an item to database
    //
    
    NSString *titre = [obj objectForKey:@"node_title"];
    NSString *nid = [obj objectForKey:@"nid"];
    
    // date format
    NSString *postDatetimeStamp = [obj objectForKey:@"node_created"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[postDatetimeStamp doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    NSString *dateFinal = [dateFormatter stringFromDate:date];
    
    // get image filename
    NSDictionary *imageArray = [obj objectForKey:@"Image"];
    NSString *imageFileName;
    if (imageArray.count >0)
        imageFileName = [imageArray objectForKey:@"filename"];
    
    // Add Entry to Article Database
    Article *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                      inManagedObjectContext:self.managedObjectContext];
    
    newEntry.title = titre;
    newEntry.nid = nid;
    newEntry.image = imageFileName;
    newEntry.postDate = dateFinal;
    newEntry.read =[NSNumber numberWithInt:0];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't new item save: %@", [error localizedDescription]);
    }
}

-(NSArray*)getAllArticles
{
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
    return self.fetchedRecordsArray.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ArticlesCell";
    ArticlesCell *cell = (ArticlesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Article *article = [self.fetchedRecordsArray objectAtIndex:indexPath.row];
    
    NSURL *imageURL = [NSURL URLWithString:[@"http://iae.philnoug.com/sites/default/files/field/image/" stringByAppendingString:article.image]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            cell.image.image = [UIImage imageWithData:imageData];
        });
    });
    
    [cell.titre setText:article.title];
    [cell.date setText:article.postDate];
    if ([article.read intValue] == 1)
        [cell.titre setTextColor:[UIColor grayColor]];

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
        Article *article = [self.fetchedRecordsArray objectAtIndex:indexPath.row];
        
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
