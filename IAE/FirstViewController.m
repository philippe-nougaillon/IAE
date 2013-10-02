//
//  FirstViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 02/10/13.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

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
            NSLog(@"Echec cde la onnection");
    }
    
    NSError *errorDecoding;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorDecoding];
    //NSLog(@"%@",json);
    
    for (NSDictionary *obj in json) {
        NSString *heure = [obj objectForKey:@"heure"];
        NSString *matiere = [obj objectForKey:@"matiere"];
        NSString *enseignant = [obj objectForKey:@"enseignant"];
        NSString *memo = [obj objectForKey:@"memo"];
        NSString *salle = [obj objectForKey:@"salle"];
        NSString *tdoptions = [obj objectForKey:@"tdoptions"];
        NSLog(@"%@ %@ %@ %@ Avec:%@ Salle:%@", heure, matiere, memo, tdoptions, enseignant, salle);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
