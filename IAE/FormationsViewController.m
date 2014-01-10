//
//  FormationsViewController.m
//  IAE
//
//  Created by admin on 06/01/2014.
//  Copyright (c) 2014 Philippe Nougaillon. All rights reserved.
//

#import "FormationsViewController.h"
#import "Formation.h"
#import "FormationDetailsViewController.h"

@interface FormationsViewController ()

@property NSArray* sections;
@property NSArray* headers;

@end

@implementation FormationsViewController

@synthesize sections = _sections;
@synthesize headers = _headers;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // load Formations from JSON file
    NSString* fileLocation = @"Formations.json";
    NSString* filePath = [[NSBundle mainBundle] pathForResource:[fileLocation stringByDeletingPathExtension] ofType:[fileLocation pathExtension]];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    
    NSError* error = nil;
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    // load each section's content
    NSArray* formations_initiales = [result objectForKey:@"initiales"];
    NSLog(@"%@", formations_initiales);
    
    NSArray* formations_continues = [result objectForKey:@"continues"];
    NSLog(@"%@", formations_continues);

    NSArray* formations_mba = [result objectForKey:@"MBA"];
    NSLog(@"%@", formations_mba);

    NSArray* formations_apprentissage = [result objectForKey:@"apprentissages"];
    NSLog(@"%@", formations_apprentissage);
    
    NSArray* formations_inter = [result objectForKey:@"Inter-entreprises"];
    NSLog(@"%@", formations_inter);

    // gather each section into one section and header array
    _sections = [NSArray arrayWithObjects:formations_initiales, formations_continues, formations_mba, formations_apprentissage, formations_inter, nil];
    _headers = [NSArray arrayWithObjects:@"Formations initiales", @"Formations continues", @"MBA", @"Apprentissage", @"Formations inter-entreprises", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_sections count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    // return the section title
    return [_headers objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary* obj = (NSDictionary*)[[_sections objectAtIndex:indexPath.section]
                                      objectAtIndex:indexPath.row];
    cell.textLabel.text = [obj objectForKey:@"title"];
    cell.detailTextLabel.text = [obj objectForKey:@"subtitle"];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // test pdf link then segeue or open url
    //

    BOOL shouldSegue = YES;
    
    if ([identifier isEqualToString:@"openFormationDetails"]) {
        
        // get the index of select item
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        
        // which formation link to open ?
        NSDictionary* obj = (NSDictionary*)[[_sections objectAtIndex:indexPath.section]
                                            objectAtIndex:indexPath.row];
        
        NSString* pdf = [obj objectForKey:@"pdf"];
        if ([pdf isEqualToString:@""]) {
            // open webpage
            NSString* url = [@"http://www.iae-paris.com/formations/" stringByAppendingString:[obj objectForKey:@"link"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            shouldSegue = NO;
        }
    }
    return shouldSegue;

}
- (IBAction)fermerButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openFormationDetails"]) {
        
        // get the index of select item
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        
        // which formation link to open ?
        NSDictionary* obj = (NSDictionary*)[[_sections objectAtIndex:indexPath.section]
                                            objectAtIndex:indexPath.row];
        
        // Get destination view
        FormationDetailsViewController *vc = [segue destinationViewController];
        
        // Pass the information to your destination view
        vc.link = [obj objectForKey:@"link"];
        vc.pdf = [obj objectForKey:@"pdf"];
        
        vc.navigationItem.title = [obj objectForKey:@"title"];
    }
}

@end
