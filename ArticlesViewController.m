//
//  ArticlesViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 24/10/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "ArticlesViewController.h"
#import "ArticlesCell.h"
#import "ArticleDetailsViewController.h"

@interface ArticlesViewController () {

    NSArray *jsonArray;
    __weak IBOutlet UITableView *articlesTableView;
}

@end

@implementation ArticlesViewController

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
    
    [self refreshButtonPressed:nil];
}

-(void)loadData
{
    // load Articles json flux
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://iae.philnoug.com/rest/articles.json"]];
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
            
            [articlesTableView reloadData];
            
            // move to top
            //[articlesTableView setContentOffset:CGPointZero animated:YES];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [activityView removeFromSuperview];
            
        });
    });
    
}


#pragma mark - Tableview Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return jsonArray.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"ArticlesCell";
    
    ArticlesCell *cell = (ArticlesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *obj = [jsonArray objectAtIndex:indexPath.row];
    NSString *titre = [obj objectForKey:@"node_title"];
    
    NSString *postDatetimeStamp = [obj objectForKey:@"node_created"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[postDatetimeStamp doubleValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSString *dateFinal = [dateFormatter stringFromDate:date];
    

    NSDictionary *imageArray = [obj objectForKey:@"Image"];
    
    //NSLog(@"imageArray = %@",imageArray);
    
    if (imageArray.count >0) {
        NSString *imageFileName = [imageArray  objectForKey:@"filename"];

        NSURL *imageURL = [NSURL URLWithString:[@"http://iae.philnoug.com/sites/default/files/field/image/" stringByAppendingString:imageFileName]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                cell.image.image = [UIImage imageWithData:imageData];
            });
        });

    }
    
    [cell.titre setText:titre];
    [cell.date setText:dateFinal];
    
    return cell;
}

# pragma mark -SEGUE

// This will get called too before the view appears
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openDetailView"]) {
        
        // get the index of select item
        ArticlesCell *cell = (ArticlesCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        // which article to open ?
        NSDictionary *obj = [jsonArray objectAtIndex:indexPath.row];
        NSString *nid = [obj objectForKey:@"nid"];
        
        // Get destination view
        ArticleDetailsViewController *vc = [segue destinationViewController];
        
        // Pass the information to your destination view
        vc.indexOfArticle = nid;
        vc.navigationItem.title = cell.titre.text;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
