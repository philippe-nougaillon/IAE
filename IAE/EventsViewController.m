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

@interface EventsViewController () {
    
    NSArray *jsonArray;
    
    IBOutlet UITableView *eventsTableView;
}

@end

@implementation EventsViewController

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
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
   [self refreshButtonPressed:nil];

}


-(void)loadData
{
    // load Events json flux
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://iae.philnoug.com/rest/events.json"]
                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data != nil) {
        //NSLog(@"Event data OK");
    } else {
        if (error != nil)
            NSLog(@"Echec connection (%@)", [error localizedDescription]);
        else
            NSLog(@"Echec de la connection");
        
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Oups..." message:@"Echec de la connection" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        alertView1.alertViewStyle = UIAlertViewStyleDefault;
        [alertView1 show];
        
        return;
    }
    
    NSError *errorDecoding;
    
    jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    
    //NSLog(@"jsonArray= %@",jsonArray);
    //NSLog(@"error= %@",errorDecoding);
    
}
- (IBAction)refreshButtonPressed:(id)sender {

    
    //Start an activity indicator here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;
    activityView.backgroundColor = [UIColor lightGrayColor];
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Call your function or whatever work that needs to be done
        //Code in this part is run on a background thread
        
        // Reload planning
        [self loadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //Stop your activity indicator or anything else with the GUI
            //Code here is run on the main thread
            
            [eventsTableView reloadData];
            
            // move to top
            //[articlesTableView setContentOffset:CGPointZero animated:YES];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [activityView removeFromSuperview];
            
        });
    });

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
    return jsonArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    EventsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *obj = [jsonArray objectAtIndex:indexPath.row];
    NSString *titre = [obj objectForKey:@"node_title"];
    NSString *soustitre = [obj objectForKey:@"subtitle"];
    
    
    NSString *dateEvent = [[obj objectForKey:@"When"] objectAtIndex:0];

    // conversion de string en date format US
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateUS = [dateFormatter dateFromString:dateEvent];

    // convertiosn date US en string FR
    NSDateFormatter *dateFormatterFR = [[NSDateFormatter alloc] init];
    [dateFormatterFR setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatterFR setDateStyle:NSDateFormatterFullStyle];
    [dateFormatterFR setLocale:[NSLocale currentLocale]];
    [dateFormatterFR setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSString *dateFR = [dateFormatterFR stringFromDate:dateUS];


    // Affichage
    [cell.titleEvent setText:titre];
    [cell.dateEvent setText:dateFR];
    [cell.subTitleEvent setText:soustitre];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

// This will get called too before the view appears
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openEventDetails"]) {
        // get the index of select item
        EventsCell *cell = (EventsCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        // which article to open ?
        NSDictionary *obj = [jsonArray objectAtIndex:indexPath.row];
        NSString *nid = [obj objectForKey:@"nid"];
        
        // Get destination view
        EventDetailsViewController *vc = [segue destinationViewController];
        
        // Pass the information to your destination view
        vc.indexOfEvent = nid;
        vc.eventTitre = cell.titleEvent.text;
        vc.eventDate = cell.dateEvent.text;
        vc.eventSubTitle = cell.subTitleEvent.text;
        vc.navigationItem.title = cell.dateEvent.text;
    }
}


@end
