//
//  ArticlesViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 24/10/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "ArticlesViewController.h"
#import "ArticlesCell.h"

@interface ArticlesViewController () {

    NSArray *jsonArray;

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
    
    [self loadData];
}


-(void)loadData
{
    // load Data from hyperplanning json flux
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://iae.philnoug.com/rest/articles.json"]];
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data != nil) {
        NSLog(@"OK");
    } else {
        if (error != nil)
            NSLog(@"Echec connection (%@)", [error localizedDescription]);
        else
            NSLog(@"Echec de la onnection");
    }
    
    NSError *errorDecoding;
    
    jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    
    NSLog(@"jsonArray= %@",jsonArray);
    NSLog(@"error= %@",errorDecoding);

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

    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
