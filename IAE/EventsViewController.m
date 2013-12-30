//
//  EventsViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 05/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "EventsViewController.h"
#import "EventsCell.h"
#import "EventDetailsViewController.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "Event.h"

@interface EventsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;
@property (nonatomic,strong)NSArray *jsonArray;
@property (nonatomic,strong)NSArray *fetchedRecordsArray;
@end

@implementation EventsViewController
@synthesize jsonArray = _jsonArray;

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

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self refreshButtonPressed:nil];
    
    // register to refresh UI when ApplicationDidBecomeActive
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(refreshListView)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    [self loadEventsData];
    
}


-(BOOL)loadData
{
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus != NotReachable) {
    
        // load Events json flux
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:[@PRODSERVER stringByAppendingString:@"rest/evenements"]]];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (data == nil) {
            if (error != nil)
                NSLog(@"Echec connection (%@)", [error localizedDescription]);
            else
                NSLog(@"Echec de la connection");
            
            //UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Oups..." message:@"Echec de la connection" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            //alertView1.alertViewStyle = UIAlertViewStyleDefault;
            //[alertView1 show];
            
            return NO;
        }
        
        NSError *errorDecoding;
        _jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
        if (errorDecoding == nil) {
            return YES;
        } else {
            NSLog(@"errorDecoding= %@",errorDecoding);
            return NO;
        }
    } else {
        NSLog(@"NOT Connected !");
        return NO;
    }
}

-(void)refreshListView {

    //Start an activity indicator here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    // Async load event content
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Rload event content
        BOOL isDataLoaded = [self loadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            // UI refresh
            if (isDataLoaded) {
                [self.eventsTableView reloadData];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [activityView removeFromSuperview];
        });
    });

}

- (IBAction)refreshButtonPressed:(id)sender {
    
    [self refreshListView];

}

-(void)loadEventsData
{
    // load data from local items or stored items
    //
    
    Reachability *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    // check if network is up
    if(remoteHostStatus != NotReachable) {
        
        NSLog(@"Load Events Data");
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
        if ([appDelegate isDatabaseExist:@"Event" ]) {
            NSLog(@"Events database exist");
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // get all items
                _fetchedRecordsArray = [self getAllEvents];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // refresh tableview with local data
                    [self.tableView reloadData];
                });
            });
        } else {
            // reload data from json and store items
            [self addAllRemoteEventsToLocalDatabase];
            _fetchedRecordsArray = [self getAllEvents];
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

-(NSArray*)getRemoteEvents {
    
    // read json remote source
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://iae.philnoug.com/rest/events.json"]];
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

-(void)refreshEventsList {
    
    NSLog(@"refreshArticlesList");
    
    // Check if remote data are more recent
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Check if remote data are more recent
        BOOL refresh = [self refreshLocalData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (refresh) {
                // refresh tableview with local data
                _fetchedRecordsArray = [self getAllEvents];
                [self.tableView reloadData];
                NSLog(@"refreshEventsList tableView reloadData");
            }
        });
    });
}

-(BOOL)refreshLocalData {
    
    //
    // check if json is more recent than local items
    //
    BOOL refreshLocalData = NO;
    
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    // check if network is up
    if(remoteHostStatus != NotReachable) {
        
        NSLog(@"refresh Local Data");
        
        // read json remote source
        NSArray *jsonArray = [self getRemoteEvents];
        
        //get first article nid
        NSDictionary *obj = [jsonArray firstObject];
        NSString *remoteEventNid = [obj objectForKey:@"nid"];
        
        // get last article in local storage
        Event *localFirstEvent = [_fetchedRecordsArray firstObject];
        int localNid = [localFirstEvent.nid intValue];
        
        // add each new remote item
        for (int index=0; index < jsonArray.count; index++) {
            
            //get Article title and date
            NSDictionary *obj = [jsonArray objectAtIndex:index];
            int remoteNid = [[obj objectForKey:@"nid"] intValue];
            
            // if remote item id is lower then last item id, add it
            if (remoteNid > localNid) {
                NSLog(@"adding item id:%@", remoteEventNid);
                
                // save Item to database
                [self addEventToLocalDatabase:obj];
                
                refreshLocalData = YES;
            }
        }
    }
    return refreshLocalData;
}

-(void)addAllRemoteEventsToLocalDatabase {
    
    // read json source
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:[@PRODSERVER stringByAppendingString:@"rest/evenements"]]];
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
        [self addEventToLocalDatabase:obj];
    }
}

-(void)addEventToLocalDatabase:(NSDictionary*)obj {
    
    // save an item to database
    //
        
    NSString *titre = [obj objectForKey:@"titre"];
    NSString *nid = [obj objectForKey:@"nid"];
    NSString *soustitre = [obj objectForKey:@"chapo"];
    NSString *dateEvent = [[obj objectForKey:@"when"] objectAtIndex:0];
    
    // conversion de string en date format US
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateUS = [dateFormatter dateFromString:dateEvent];
    
    // conversion date US en string FR
    NSDateFormatter *dateFormatterFR = [[NSDateFormatter alloc] init];
    [dateFormatterFR setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatterFR setDateStyle:NSDateFormatterFullStyle];
    [dateFormatterFR setLocale:[NSLocale currentLocale]];
    //[dateFormatterFR setDateFormat:@"dd MMM yyyy HH:mm"];
    [dateFormatterFR setDateFormat:@"dd MMM"];
    NSString *dateFR = [dateFormatterFR stringFromDate:dateUS];
    
    // Add Entry to Article Database
    Event *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                      inManagedObjectContext:self.managedObjectContext];
    
    newEntry.title = titre;
    newEntry.nid = nid;
    newEntry.subtitle = soustitre;
    newEntry.when = dateFR;
    newEntry.read =[NSNumber numberWithInt:0];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't new item save: %@", [error localizedDescription]);
    }
}

-(NSArray*)getAllEvents
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"when" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _fetchedRecordsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    UIColor *blueIAE = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:128/255.0 alpha:1];

    EventsCell *cell = (EventsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // update cell with article content
    Event *event = [_fetchedRecordsArray objectAtIndex:indexPath.row];
    [cell.titleEvent setText:event.title];
    [cell.subTitleEvent setText:event.subtitle];
    [cell.dateEvent setText:event.when];

    // change title color if item already marked as read
    if ([event.read intValue] == 1)
        [cell.titleEvent setTextColor:[UIColor grayColor]];
    else
        [cell.titleEvent setTextColor:blueIAE];

    // show calendar if event was added to user calendar
    if ([event.addedToCalendar intValue] == 1) {
        [cell.eventIsIntoCalendar setHidden:NO];
        [cell.labelEventAddedToCalendar setHidden:NO];
    }
    
    return cell;
}

// This will get called too before the view appears
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openEventDetails"]) {
        // get the index of select item
        EventsCell *cell = (EventsCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        // which article to open ?
        Event *event = [_fetchedRecordsArray objectAtIndex:indexPath.row];
        
        //mark event as read
        event.read = [NSNumber numberWithInt:1];
        [cell.titleEvent setTextColor:[UIColor grayColor]];
        
        // update the database
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        // Get destination view
        EventDetailsViewController *vc = [segue destinationViewController];
        
        // Pass the information to your destination view
        vc.indexOfEvent = event.nid;
        vc.eventTitre = event.title;
        vc.eventDate = event.when;
        vc.eventAddedToCalendar = event.addedToCalendar;
    }
}


@end
