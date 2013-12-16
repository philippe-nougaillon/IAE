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


@interface ArticlesTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *articlesTableView;
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
    
    // get localdata or remote if first launch
    [self loadData];

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

        NSLog(@"loadata");
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
        if (appDelegate.isDatabaseExist) {
            NSLog(@"loadata database exist");

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // get all items
                self.fetchedRecordsArray = [self getAllArticles];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // refresh tableview with local data
                    [self.tableView reloadData];
                });
            });
        } else {
            // reload data from json and store items
            [self addAllRemoteArticlesToLocalDatabase];
            self.fetchedRecordsArray = [self getAllArticles];
            [self.tableView reloadData];
        }
        // hide activity monitor
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [activityView removeFromSuperview];
    } else {
        NSLog(@"NOT Connected !");
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Pas de connection" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        alertView1.alertViewStyle = UIAlertViewStyleDefault;
        [alertView1 show];
    }
}


- (IBAction)refreshButtonPressed:(id)sender {
    
    [self refreshArticlesList];

}

-(NSArray*)getRemoteArticles {
    
    // read json remote source
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://iae.philnoug.com/rest/articles.json"]];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil) {
        NSArray *jsonArray;
        NSError *errorDecoding;
        jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
        return jsonArray;
    }
    else
        return nil;
    
}

-(void)refreshArticlesList {
    
    NSLog(@"refreshArticlesList");

    // Check if remote data are more recent
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Check if remote data are more recent
        BOOL refresh = [self refreshLocalData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (refresh) {
                // refresh tableview with local data
                self.fetchedRecordsArray = [self getAllArticles];
                [self.tableView reloadData];
                NSLog(@"refreshArticlesList tableView reloadData");
            }
        });
    });
}

-(BOOL)refreshLocalData {
    
    //
    // check if json is more recent than local items
    //
    BOOL refreshLocalData = NO;
    
    Reachability *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    // check if network is up
    if(remoteHostStatus != NotReachable) {
 
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
    if (data == nil) {
        if (error != nil)
            NSLog(@"Echec connection (%@)", [error localizedDescription]);
        else
            NSLog(@"Echec de la connection");
        
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Echec de la connection" message:@"Il semble que vous n'avez pas accès à internet." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        alertView1.alertViewStyle = UIAlertViewStyleDefault;
        [alertView1 show];
    }
    
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
    NSString *filePathToImage;
    NSDictionary *imageArray = [obj objectForKey:@"Image"];
    if (imageArray.count >0) {
        NSString *imageFileName = [imageArray objectForKey:@"filename"];
        
        // load image
        NSURL *imageURL = [NSURL URLWithString:[@"http://iae.philnoug.com/sites/default/files/field/image/"         stringByAppendingString:imageFileName]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        // save image into app's document folder
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        filePathToImage = [NSString stringWithFormat:@"%@/%@", documentsDirectory, imageFileName];
        [imageData writeToFile:filePathToImage atomically:NO];
    }

    // Add Entry to Article Database
    Article *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                      inManagedObjectContext:self.managedObjectContext];
    
    newEntry.title = titre;
    newEntry.nid = nid;
    newEntry.image = filePathToImage;
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
    static NSString *cellIdentifier = @"ArticleCell";
    UIColor *blueIAE = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1];

    ArticlesCell *cell = (ArticlesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
    // update cell with article content
    Article *article = [self.fetchedRecordsArray objectAtIndex:indexPath.row];
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
