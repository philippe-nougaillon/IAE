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

@interface EventsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;
@property (nonatomic,strong)NSArray *jsonArray;
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
}

-(BOOL)loadData
{
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus != NotReachable) {
    
        // load Events json flux
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:@"http://iae.philnoug.com/rest/events.json"]
                                 ];
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
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center=self.view.center;
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
    return _jsonArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    EventsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *obj = [_jsonArray objectAtIndex:indexPath.row];
    NSString *titre = [obj objectForKey:@"node_title"];
    NSString *soustitre = [obj objectForKey:@"subtitle"];
    NSString *dateEvent = [[obj objectForKey:@"When"] objectAtIndex:0];

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

    // Affichage cellule
    [cell.titleEvent setText:titre];
    [cell.dateEvent setText:dateFR];
    [cell.subTitleEvent setText:soustitre];
    
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
        NSDictionary *obj = [_jsonArray objectAtIndex:indexPath.row];
        NSString *nid = [obj objectForKey:@"nid"];
        
        // Get destination view
        EventDetailsViewController *vc = [segue destinationViewController];
        
        // Pass the information to your destination view
        vc.indexOfEvent = nid;
        vc.eventTitre = cell.titleEvent.text;
        vc.eventDate = cell.dateEvent.text;
    }
}


@end
