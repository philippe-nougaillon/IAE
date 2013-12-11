//
//  ArticleDetailsViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 04/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "ArticleDetailsViewController.h"
#import "Reachability.h"

@interface ArticleDetailsViewController ()
{
    __weak IBOutlet UIWebView *articleWebview;
}
@property (nonatomic,strong)NSDictionary *jsonArray;

@end

@implementation ArticleDetailsViewController

@synthesize indexOfArticle = _indexOfArticle;

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

    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus != NotReachable) {
        
        // load Data from hyperplanning json flux
        NSString *url = [@"http://iae.philnoug.com/rest/node/" stringByAppendingString:_indexOfArticle];
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
        self.jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
        if (errorDecoding == nil) {
            //NSLog(@"jsonArray= %@",jsonArray);
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Start an activity indicator here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Call your function or whatever work that needs to be done
        //Code in this part is run on a background thread
        
        // Reload planning
        BOOL isDataloaded = [self loadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {

            //Stop your activity indicator or anything else with the GUI
            //Code here is run on the main thread
            if (isDataloaded) {
                NSDictionary  *body = [self.jsonArray objectForKey:@"body"];
                NSArray  *und = [body objectForKey:@"und"];
                NSString *textArticle =[[und objectAtIndex:0] objectForKey:@"safe_value"];
                [articleWebview loadHTMLString:textArticle baseURL:nil];
            }
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
