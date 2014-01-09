//
//  FormationDetailsViewController.m
//  IAE
//
//  Created by admin on 06/01/2014.
//  Copyright (c) 2014 Philippe Nougaillon. All rights reserved.
//

#import "FormationDetailsViewController.h"

@interface FormationDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myProgressView;

@end

@implementation FormationDetailsViewController

@synthesize link = _link;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.myProgressView startAnimating];
    NSString* pdf = [@"http://www.iae-paris.com/sites/default/files/" stringByAppendingString:self.pdf];
    
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pdf]]];

}

- (IBAction)openWebSite:(id)sender {
    
    NSString* url = [@"http://www.iae-paris.com/formations/" stringByAppendingString:self.link];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    // stop progress indicator
    [self.myProgressView stopAnimating];
    [self.myProgressView setHidden:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
