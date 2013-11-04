//
//  ArticleDetailsViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 04/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "ArticleDetailsViewController.h"

@interface ArticleDetailsViewController (){
    
    NSDictionary *jsonArray;
    
    __weak IBOutlet UIImageView *imageDetail;
    __weak IBOutlet UITextView *textDetail;
}

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

-(void)loadData
{
    // load Data from hyperplanning json flux
    
    NSLog(@"index article : %@", _indexOfArticle);

    NSString *url = [@"http://iae.philnoug.com/rest/node/" stringByAppendingString:_indexOfArticle];
    url = [url stringByAppendingString:@".json"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data != nil) {
        //NSLog(@"OK");
    } else {
        if (error != nil)
            NSLog(@"Echec connection (%@)", [error localizedDescription]);
        else
            NSLog(@"Echec de la connection");
    }
    
    NSError *errorDecoding;
    
    jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    
    NSLog(@"jsonArray= %@",jsonArray);
    NSLog(@"error= %@",errorDecoding);
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadData];
    
    
    NSDictionary  *body = [jsonArray objectForKey:@"body"];
    NSDictionary  *und = [body objectForKey:@"und"];

    NSString *textArticle = [und objectForKey:@"safe_value"];
    
    
    [textDetail setText:textArticle];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
