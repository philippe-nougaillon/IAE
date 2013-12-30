//
//  EventDetailsViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 06/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "Reachability.h"
#import "EventKit/EventKit.h"
#import "Event.h"
#import "AppDelegate.h"

@interface EventDetailsViewController ()
@property (nonatomic,strong) NSArray *jsonArray;
@property (nonatomic,strong) NSDate *eventDateUS;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIWebView *articleWebview;
@property (weak, nonatomic) IBOutlet UILabel *dateEvent;
@property (nonatomic,strong) NSArray *fetchedRecordsArray;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonAddToCalendar;
@end

@implementation EventDetailsViewController

@synthesize indexOfEvent = _indexOfEvent;
@synthesize jsonArray = _jsonArray;
@synthesize fetchedRecordsArray = _fetchedRecordsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)loadData
{    
    Reachability  *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus != NotReachable) {
    
        // load Data from hyperplanning json flux
        NSString *url = [@PRODSERVER stringByAppendingString:@"rest/evenements/"];
        url = [url stringByAppendingString:_indexOfEvent];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
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
        return NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
 
    [self.labelTitle setText:self.eventTitre];
    [self.dateEvent setText:self.eventDate];
    if ([self.eventAddedToCalendar isEqualToNumber:@1])
        [self.buttonAddToCalendar setEnabled:NO];
    else
        [self.buttonAddToCalendar setEnabled:YES];
    
    // load event details
    //
    //Start an activity indicator here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Reload event detail
        BOOL isDataLoaded = [self loadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (isDataLoaded) {
                // get event details
                NSDictionary *obj = [_jsonArray objectAtIndex:0];
                NSString *textArticle = [obj objectForKey:@"contenu"];
                [self.articleWebview loadHTMLString:textArticle baseURL:nil];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
        });
    });
}


- (IBAction)addEventButtonPressed:(id)sender {

    // add event to device calendar
    //
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        // add to calendar
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) { return; }
            EKEvent *event = [EKEvent eventWithEventStore:store];
            event.title = self.eventTitre;
            event.startDate = self.eventDateUS;
            event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
            [event setCalendar:[store defaultCalendarForNewEvents]];
            NSError *err = nil;
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
            //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later

        }];
        
         dispatch_async(dispatch_get_main_queue(), ^(void) {
             // Update UI
             NSString *msg = [@"Ajouté à votre agenda au " stringByAppendingString:self.eventDate];
             UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:self.eventTitre message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
             alertView1.alertViewStyle = UIAlertViewStyleDefault;
             [alertView1 show];
             // hide button
             [self.buttonAddToCalendar setEnabled:NO];
             // mark event as added to calendar and store it
             [self markEventAsAddedToCalendar:self.indexOfEvent];
         });
    });
    
}

-(void)markEventAsAddedToCalendar:(NSString*)indexOfEvent {
    
    // mark event as added to calendar and store it
    //

    // find event to open and mark it
    [self getAllEvents];
    Event *event = [_fetchedRecordsArray objectAtIndex:0];
    
    //mark event as added to calendar
    event.addedToCalendar = [NSNumber numberWithInt:1];
    
    // update the database
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
}

-(void)getAllEvents
{
    
    // setup database context
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // filter for event nid
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"nid == %@", self.indexOfEvent];
    [fetchRequest setPredicate:predicate];
    
    // Query on managedObjectContext With Generated fetchRequest
    NSError* error;
    _fetchedRecordsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
