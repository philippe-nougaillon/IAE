//
//  FirstViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 02/10/13.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "FirstViewController.h"
#import "Cell.h"

@interface FirstViewController () {

    NSArray *jsonArray;
    //NSDictionary *jsonDictionary;
    
}

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self loadData];

}

-(void)loadData
{

    // load Data from hyperplanning json flux

    NSURLRequest *request = [NSURLRequest requestWithURL:
                                    [NSURL URLWithString:@"https://entiae.univ-paris1.fr/hyperjson/index.php"]];
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

    //jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    
    jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];

    //NSLog(@"%@",jsonArray);

    /*
    
    for (NSInteger i = 0; i < jsonDictionary.count; i++ ) {
        NSString *key = [NSString stringWithFormat:@"%d", i];
        NSDictionary *obj = [jsonDictionary objectForKey:key];
        NSString *heure = [obj objectForKey:@"heure"];
        NSLog(@"%@",heure);
    }
     */

    /*

    for (NSDictionary *obj in jsonArray) {
        NSString *heure = [obj objectForKey:@"heure"];
        NSString *matiere = [obj objectForKey:@"matiere"];
        NSString *enseignant = [obj objectForKey:@"enseignant"];
        NSString *memo = [obj objectForKey:@"memo"];
        NSString *salle = [obj objectForKey:@"salle"];
        NSString *tdoptions = [obj objectForKey:@"tdoptions"];
        NSLog(@"%@ %@ %@ %@ Avec:%@ Salle:%@", heure, matiere, memo, tdoptions, enseignant, salle);
     }

    */
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
    
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
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
