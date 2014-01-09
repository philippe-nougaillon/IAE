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
@property (nonatomic,strong) NSArray *jsonArray;
@property (weak, nonatomic) IBOutlet UIWebView *articleWebview;
@end

@implementation ArticleDetailsViewController

@synthesize indexOfArticle = _indexOfArticle;
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

    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus != NotReachable) {
        
        // load Data from hyperplanning json flux
        NSString *url = [@PRODSERVER stringByAppendingString:@"rest/actualites/"];
        url = [url stringByAppendingString:_indexOfArticle];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLResponse *response;
        NSError *error;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (data == nil) {
            if (error != nil)
                NSLog(@"Echec connection (%@)", [error localizedDescription]);
            else
                NSLog(@"Echec de la connection");
            
            return NO;
        }
        NSError *errorDecoding;
        _jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
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

    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];

    // async load of article content
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // load article content
        BOOL isDataloaded = [self loadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
             // update webview
             if (isDataloaded) {
                //NSDictionary  *body = [_jsonArray objectForKey:@"contenu"];
                //NSArray  *und = [body objectForKey:@"und"];
                //NSString *textArticle =[[und objectAtIndex:0] objectForKey:@"safe_value"];
                 
                NSDictionary *obj = [_jsonArray objectAtIndex:0];
                NSString *textArticle = [obj objectForKey:@"contenu"];
                [self.articleWebview loadHTMLString:textArticle baseURL:nil];
            }
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

@end
