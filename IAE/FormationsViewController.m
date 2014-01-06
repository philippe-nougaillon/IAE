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

@property NSArray* formations_initiales;
@property NSArray* formations_continues;
@property NSArray* formations_apprentissage;

@property NSArray* sections;
@property NSArray* headers;

@end

@implementation FormationsViewController

@synthesize formations_initiales = _formations_initiales;
@synthesize formations_continues = _formations_continues;
@synthesize formations_apprentissage = _formations_apprentissage;
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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    Formation* fa1 = [[Formation alloc] init];
    fa1.title = @"Licence DISTRISUP";
    fa1.subtitle = @"Commerce et Distribution";
    fa1.link = @"http://www.iae-paris.com/formations/formation-initiale/licence-commerce-distribution-distrisup-apprentissage";
    fa1.pdf = @"http://www.iae-paris.com/sites/default/files/Brochure%20de%20presentation%20Licence%20DISTRISUP.pdf";
    
    Formation* fa2 = [[Formation alloc] init];
    fa2.title = @"Master MAE";
    fa2.subtitle = @"Administration des Entreprises - Gestion des dynamiques organisationnelles";
    
    Formation* fa3 = [[Formation alloc] init];
    fa3.title = @"Master Contrôle-Audit";
    fa3.subtitle = @"Audit - Contrôle de gestion";
 
    Formation* fa4 = [[Formation alloc] init];
    fa4.title = @"Master Finance";
    fa4.subtitle = @"Finance";
    
    Formation* fa5 = [[Formation alloc] init];
    fa5.title = @"Master Management";
    fa5.subtitle = @"Audit, Contrôle de gestion, Finance, Management, Gestion, Marketing, RH - RSE";

    Formation* fa6 = [[Formation alloc] init];
    fa6.title = @"Master RH - RSE";
    fa6.subtitle = @"Ressources Humaines & Responsabilité Sociale de l'Entreprise";
    
    _formations_apprentissage = [NSArray arrayWithObjects:fa1, fa2, fa3, fa4, fa5, fa6, nil];
    
    
    Formation* fi1 = [[Formation alloc] init];
    fi1.title = @"Formation initiale 1";
    
    _formations_initiales = [NSArray arrayWithObjects:fi1, nil];

    Formation* fc1 = [[Formation alloc] init];
    fc1.title = @"Formation continue 1";

    _formations_continues = [NSArray arrayWithObjects:fc1, nil];
    
    _sections = [NSArray arrayWithObjects:_formations_apprentissage,_formations_initiales, _formations_continues, nil];

    _headers = [NSArray arrayWithObjects:@"Apprentissage",@"Formations initiales", @"Formations continues", nil];
    
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
    
    Formation* f = (Formation*)[[_sections objectAtIndex:indexPath.section]
                                      objectAtIndex:indexPath.row];
    cell.textLabel.text = f.title;
    cell.detailTextLabel.text = f.subtitle;
    
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openFormationDetails"]) {
        
        // get the index of select item
        UITableViewCell* cell = (UITableViewCell*)sender;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        
        // which formation link to open ?
        Formation* f = (Formation*)[[_sections objectAtIndex:indexPath.section]
                                    objectAtIndex:indexPath.row];
        
        
        // Get destination view
        FormationDetailsViewController *vc = [segue destinationViewController];
        
        // Pass the information to your destination view
        vc.link = f.link;
        vc.navigationItem.title = f.title;
    }
}

@end
