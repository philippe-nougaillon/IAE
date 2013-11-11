//
//  FirstViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 02/10/13.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "PlanningViewController.h"
#import "PlanningCell.h"

@interface PlanningViewController () {

    NSArray *jsonArray;
    
    __weak IBOutlet UITableView *planningTableView;
}

@end

@implementation PlanningViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;

    // change navigation bar background
    [self.navigationController.navigationBar
     setBackgroundImage:[UIImage imageNamed:@"navBar.png"]
     forBarMetrics:UIBarMetricsDefault];

    [self refreshButtonPressed:nil];
    
    // register to refresh UI when ApplicationDidBecomeActive
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(refreshListView)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

-(void)loadData
{
    // load Data from hyperplanning json flux

    NSURLRequest *request = [NSURLRequest requestWithURL:
                                    [NSURL URLWithString:@"https://entiae.univ-paris1.fr/hyperjson/index.php"]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data != nil) {
        //NSLog(@"OK");
    } else {
        if (error != nil)
            NSLog(@"Echec connection (%@)", [error localizedDescription]);
        else
            NSLog(@"Echec de la onnection");
        
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Oups..." message:@"Echec de la connection" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        alertView1.alertViewStyle = UIAlertViewStyleDefault;
        [alertView1 show];
        
        return;

    }
    NSError *errorDecoding;
    jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    //NSLog(@"%@",jsonArray);
}

-(void)refreshListView{

    //Start an activity indicator here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center=self.view.center;
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
            
            [planningTableView reloadData];
            
            // move to top
            //[planningTableView setContentOffset:CGPointZero animated:YES];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [activityView removeFromSuperview];
            
        });
    });

}

- (IBAction)refreshButtonPressed:(id)sender {

    [self refreshListView];

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

    static NSString *cellIdentifier = @"Cell";
    
    PlanningCell *cell = (PlanningCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *obj = [jsonArray objectAtIndex:indexPath.row];
    NSString *heure = [obj objectForKey:@"heure"];
    NSString *matiere = [obj objectForKey:@"matiere"];
    NSString *enseignant = [obj objectForKey:@"enseignant"];
    NSString *memo = [obj objectForKey:@"memo"];
    NSString *salle = [obj objectForKey:@"salle"];
    NSString *tdoptions = [obj objectForKey:@"tdoptions"];

    //NSLog(@"%@ %@ %@ %@ Avec:%@ Salle:%@", heure, matiere, memo, tdoptions, enseignant, salle);
    
    [cell.heureLabel setText:heure];
    [cell.titreLabel setText:matiere];
    [cell.salleLabel setText:salle];
    
    if ([memo isEqualToString:@""] && ![tdoptions isEqualToString:@""]) {
        [cell.subTitleLabel setText:tdoptions];
    } else
        [cell.subTitleLabel setText:memo];

    if ([enseignant isEqualToString:@""] && ![tdoptions isEqualToString:@""]) {
        [cell.memoLabel setText:tdoptions];
    } else
        [cell.memoLabel setText:enseignant];
    
    return cell;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
