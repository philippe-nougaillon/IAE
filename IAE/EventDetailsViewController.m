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

@interface EventDetailsViewController ()
@property (nonatomic,strong)NSDictionary *jsonArray;
@property (nonatomic,strong)NSDate *eventDateUS;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIWebView *articleWebview;
@property (weak, nonatomic) IBOutlet UILabel *dateEvent;
@end

@implementation EventDetailsViewController

@synthesize indexOfEvent = _indexOfEvent;
@synthesize jsonArray = _jsonArray;

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
        NSString *url = [@"http://iae.philnoug.com/rest/node/" stringByAppendingString:_indexOfEvent];
        url = [url stringByAppendingString:@".json"];
        
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
 
    // load event details
    //
    //Start an activity indicator here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Reload event detail
        BOOL isDataLoaded = [self loadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (isDataLoaded) {
                NSDictionary  *body = [_jsonArray objectForKey:@"body"];
                NSArray  *und = [body objectForKey:@"und"];
                
                NSString *textArticle =[[und objectAtIndex:0] objectForKey:@"safe_value"];
                [self.articleWebview loadHTMLString:textArticle baseURL:nil];
                
                // Get event full event date
                body = [_jsonArray objectForKey:@"field_when"];
                und = [body objectForKey:@"und"];
                NSString *dateWhen = [[und objectAtIndex:0] objectForKey:@"value"];
                
                // convert date
                NSDateFormatter *dateFormatterUS = [[NSDateFormatter alloc] init];
                [dateFormatterUS setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                self.eventDateUS = [dateFormatterUS dateFromString:dateWhen];
                
                [self.dateEvent setText:self.eventDate];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
        });
    });
}


- (IBAction)addEventButtonPressed:(id)sender {

    // add event to device calendar
    //
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
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
         });
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
