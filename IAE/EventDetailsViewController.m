//
//  EventDetailsViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 06/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController () {

    NSDictionary *jsonArray;
    
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelDate;
    __weak IBOutlet UILabel *labelSubTitle;
    __weak IBOutlet UIWebView *articleWebview;
}

@end

@implementation EventDetailsViewController

@synthesize indexOfEvent = _indexOfEvent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadData
{
    // load Data from hyperplanning json flux
    
    NSLog(@"index event : %@", _indexOfEvent);
    
    NSString *url = [@"http://iae.philnoug.com/rest/node/" stringByAppendingString:_indexOfEvent];
    url = [url stringByAppendingString:@".json"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data != nil) {
        NSLog(@"Event details data OK");
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
 
    [labelTitle setText:self.eventTitre];
    [labelDate setText:self.eventDate];
    //[labelSubTitle setText:self.eventSubTitle];
 
    // load event details
    //Start an activity indicator here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Call your function or whatever work that needs to be done
        //Code in this part is run on a background thread
        
        // Reload planning
        [self loadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //Stop your activity indicator or anything else with the GUI
            //Code here is run on the main thread
            
            NSDictionary  *body = [jsonArray objectForKey:@"body"];
            NSArray  *und = [body objectForKey:@"und"];
            NSString *textArticle =[[und objectAtIndex:0] objectForKey:@"safe_value"];
            
            [articleWebview loadHTMLString:textArticle baseURL:nil];
            
            // move to top
            //[articlesTableView setContentOffset:CGPointZero animated:YES];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
        });
    });
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
