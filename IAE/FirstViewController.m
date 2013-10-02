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

}

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://entiae.univ-paris1.fr/hyperjson/"]];
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
    //NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];

    //NSLog(@"%@",json);
    
    for (NSDictionary *obj in jsonArray) {
        NSString *heure = [obj objectForKey:@"heure"];
        NSString *matiere = [obj objectForKey:@"matiere"];
        NSString *enseignant = [obj objectForKey:@"enseignant"];
        NSString *memo = [obj objectForKey:@"memo"];
        NSString *salle = [obj objectForKey:@"salle"];
        NSString *tdoptions = [obj objectForKey:@"tdoptions"];
        NSLog(@"%@ %@ %@ %@ Avec:%@ Salle:%@", heure, matiere, memo, tdoptions, enseignant, salle);
    }
    
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
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    
    NSDictionary *obj = [jsonArray objectAtIndex:indexPath.row];
    NSString *heure = [obj objectForKey:@"heure"];
    
    [cell.heureLabel setText:heure];
    
    return cell;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
