//
//  FirstViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 02/10/13.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "PlanningViewController.h"
#import "PlanningCell.h"
#import "NSArray+arrayWithContentsOfJSONFile.h"

@interface PlanningViewController ()
@property (nonatomic,strong) NSArray *jsonArray;
@property (nonatomic,strong) NSArray *originalPlanningArray;
@property (weak, nonatomic) IBOutlet UITableView *planningTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *theSearchBar;
@end

@implementation PlanningViewController

@synthesize theSearchBar = _theSearchBar;
@synthesize jsonArray = _jsonArray;
@synthesize originalPlanningArray = _originalPlanningArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self refreshListView];
}

- (void)viewDidAppear:(BOOL)animated
{

    // register to refresh UI when ApplicationDidBecomeActive
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(refreshListView)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Planning"
                                                      forKey:kGAIScreenName] build]];

}

-(void)refreshListView{
    
    // load Data from hyperplanning json flux
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus != NotReachable) {

        //NSLog(@"[Planning]refreshListView->Connection OK");

        // remove all notification observer for this view
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        // Start an activity indicator here
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        UIActivityIndicatorView *activityView =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center = self.view.center;
        [activityView startAnimating];
        [self.view addSubview:activityView];
        
        // async load planning
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Reload planning
            _jsonArray = [NSArray arrayWithContentsOfJSONFile:@"https://entiae.univ-paris1.fr/hyperjson/index.php"];
            _originalPlanningArray = _jsonArray;
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                // Update UI
                [self.planningTableView reloadData];
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [activityView removeFromSuperview];
                
                // register to refresh UI when ApplicationDidBecomeActive
                [[NSNotificationCenter defaultCenter]addObserver:self
                                                        selector:@selector(refreshListView)
                                                            name:UIApplicationDidBecomeActiveNotification
                                                          object:nil];
            });
        });
    }
}

- (IBAction)refreshButtonPressed:(id)sender {

    [self refreshListView];
}


#pragma mark - SearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchBarText {

    //NSLog(@"searchBar SearchButtonClicked text:%@", searchBarText);
    [self filterArrayFromSearchBarText:searchBarText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    //NSLog(@"searchBar SearchButton Clicked");
    [self filterArrayFromSearchBarText:searchBar.text];

}

- (void)filterArrayFromSearchBarText:(NSString *)searchBarText {

    if (![searchBarText isEqualToString:@""]) {
        // filter planning array according to entered text
        NSArray *propertyName = [[NSArray alloc] initWithObjects:@"memo", @"tdoptions", @"enseignant", @"matiere", @"heure", @"salle", nil];
        NSPredicate *predicte = [NSPredicate predicateWithFormat:@"(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)", [propertyName objectAtIndex:0] , searchBarText, [propertyName objectAtIndex:1], searchBarText, [propertyName objectAtIndex:2], searchBarText, [propertyName objectAtIndex:3], searchBarText, [propertyName objectAtIndex:4], searchBarText, [propertyName objectAtIndex:5], searchBarText];
        NSArray *filteredArray = [_originalPlanningArray filteredArrayUsingPredicate:predicte];
        _jsonArray = filteredArray;
    } else {
        _jsonArray = _originalPlanningArray;
    }
    [self.planningTableView reloadData];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    // restore original planning array
    _jsonArray = _originalPlanningArray;
    [self.planningTableView reloadData];
    
    // clear search entry
    [_theSearchBar setText:@""];

    // clean search entry
    [_theSearchBar setText:@""];
    
    // hide keyboard
    [_theSearchBar resignFirstResponder];
    //NSLog(@"searchBar CancelButtonClicked");
}

#pragma mark - Tableview Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return _jsonArray.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    PlanningCell *cell = (PlanningCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary *obj = [_jsonArray objectAtIndex:indexPath.row];
    NSString *heure = [obj objectForKey:@"heure"];
    NSString *matiere = [obj objectForKey:@"matiere"];
    NSString *enseignant = [obj objectForKey:@"enseignant"];
    NSString *memo = [obj objectForKey:@"memo"];
    NSString *salle = [obj objectForKey:@"salle"];
    NSString *tdoptions = [obj objectForKey:@"tdoptions"];

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
