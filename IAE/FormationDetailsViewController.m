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
    
    // Test if pdf exist in documents folder
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePathToPDF = [NSString stringWithFormat:@"%@/%@", documentsDirectory, self.pdf];
    NSURLRequest* myRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePathToPDF]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePathToPDF];
    
    if (!fileExists) {
        // async load the PDF file
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString* url = [@"http://www.iae-paris.com/sites/default/files/" stringByAppendingString:self.pdf];
            NSData* fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            
            // save PDF
            NSError *error = nil;
            if (![fileData writeToFile:filePathToPDF options:NSDataWritingAtomic error:&error]) {
                NSLog(@"Unable to write PDF to %@. Error: %@", filePathToPDF, error);
            }
            fileData = nil;
            
            // update UI
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                // open pdf in local documents folder...
                [self.myWebView loadRequest:myRequest];
            });
        });
    } else {
        [self.myWebView loadRequest:myRequest];
    }
}

- (IBAction)openWebSite:(id)sender {
    
    NSString* url = [@"http://www.iae-paris.com/formations/" stringByAppendingString:self.link];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [self.myProgressView stopAnimating];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
